#!/usr/bin/env bash
#
# new-service.sh - Amorce un nouveau service morfSystem a partir de ce gabarit.
#
# Copie tout le projet dans un nouveau dossier en remplacant les noms :
#     morfTemplateService  -> <NomCamel>   (projet / bibliotheque / cible CMake)
#     morftemplate         -> <nom>        (namespace, dossier include, binaire,
#                                           unite systemd, fichier de config)
#     MORFTEMPLATE         -> <NOM>        (prefixe de macro)
#
# Le projet genere ne garde AUCUNE trace du gabarit : les fichiers qui le
# decrivent sont supprimes, README / CHANGELOG / VERSION sont repartis de zero
# (scripts/skeleton/), et un controle final signale tout reste.
#
# Usage :
#     scripts/new-service.sh <nom> <NomCamel> [dossier_destination]
# Exemple :
#     scripts/new-service.sh morfwatch morfWatch
#       -> cree ../morfWatch_travail, pret a compiler, ou coder le metier.

set -euo pipefail

LOWER="${1:-}"; CAMEL="${2:-}"
if [[ -z "$LOWER" || -z "$CAMEL" ]]; then
    echo "Usage : $0 <nom-minuscule> <NomCamel> [dossier_destination]" >&2
    echo "Ex.   : $0 morfwatch morfWatch" >&2
    exit 1
fi
UPPER="$(echo "$LOWER" | tr '[:lower:]' '[:upper:]')"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST="${3:-$(cd "$ROOT/.." && pwd)/${CAMEL}_travail}"

if [[ -e "$DEST" ]]; then
    echo "Destination deja existante : $DEST" >&2
    exit 1
fi

echo "Gabarit : $ROOT"
echo "Nouveau : $DEST  ($CAMEL / $LOWER / $UPPER)"

# --- 1. Copier l'arbre (sans .git ni artefacts de build) -----------------
mkdir -p "$DEST"
if command -v rsync >/dev/null; then
    rsync -a --exclude='.git' --exclude='build' --exclude='build-*' "$ROOT"/ "$DEST"/
else
    cp -a "$ROOT"/. "$DEST"/
    rm -rf "$DEST/.git" "$DEST"/build "$DEST"/build-* 2>/dev/null || true
fi

# --- 2. Retirer ce qui ne concerne que le gabarit, poser les docs du projet
# Les squelettes (README, CHANGELOG, index de docs) remplacent ceux du gabarit ;
# les scripts de clonage, la roadmap, le guide de contribution et le guide
# d'integration decrivent le gabarit et n'ont aucun sens dans le projet genere.
SKEL="$DEST/scripts/skeleton"
cp "$SKEL/README.md"         "$DEST/README.md"
cp "$SKEL/README.fr.md"      "$DEST/README.fr.md"
cp "$SKEL/CHANGELOG.md"      "$DEST/CHANGELOG.md"
cp "$SKEL/docs-fr-README.md" "$DEST/docs/fr/README.md"
cp "$SKEL/docs-en-README.md" "$DEST/docs/en/README.md"
rm -rf "$SKEL" "$DEST/scripts/new-service.sh" "$DEST/scripts/new-service.ps1" \
       "$DEST/ROADMAP.md" "$DEST/CONTRIBUTING.md" "$DEST/docs/fr/INTEGRATION.md"
printf '0.1.0\n' > "$DEST/VERSION"

# Le projet genere est un service ordinaire : plus de drapeau de gabarit dans
# service.json (il ferait sauter le service a l'installation) et type
# « service » dans morfproject.json.
sed -i -e '/"_comment_template"/d' -e '/"template": true/d' "$DEST/service.json"
sed -i -e 's/"type": "template"/"type": "service"/' "$DEST/morfproject.json"

# --- 3. Remplacer les jetons dans tous les fichiers texte ----------------
# (on ne touche pas a third_party/, code vendore de morfBeacon)
TODAY="$(date +%Y-%m-%d)"
grep -rlZ --binary-files=without-match \
     -e 'morfTemplateService' -e 'morftemplate' -e 'MORFTEMPLATE' -e '@DATE@' -e '@YEAR@' \
     "$DEST" 2>/dev/null | while IFS= read -r -d '' f; do
    case "$f" in */third_party/morf/beacon/*) continue;; esac  # ne pas toucher au code vendore
    sed -i -e "s/morfTemplateService/$CAMEL/g" \
           -e "s/morftemplate/$LOWER/g" \
           -e "s/MORFTEMPLATE/$UPPER/g" \
           -e "s/@DATE@/$TODAY/g" -e "s/@YEAR@/${TODAY%%-*}/g" "$f"
done

# --- 4. Renommer les fichiers/dossiers portant l'ancien nom --------------
mv "$DEST/include/morftemplate"                 "$DEST/include/$LOWER"
mv "$DEST/config/morftemplate.example.json"     "$DEST/config/$LOWER.example.json"
mv "$DEST/scripts/linux/morftemplate.service"   "$DEST/scripts/linux/$LOWER.service"

# --- 5. Controle : aucune trace du gabarit ne doit subsister --------------
# Simple avertissement (un nom de projet peut legitimement contenir
# « template »), mais toute occurrence est a relire.
LEFT="$(grep -rIniE 'template|gabarit' "$DEST" \
        --exclude-dir=third_party --exclude-dir=.github 2>/dev/null || true)"
if [ -n "$LEFT" ]; then
    echo "ATTENTION : traces du gabarit restantes dans le projet genere :" >&2
    echo "$LEFT" >&2
fi

echo "Termine."
echo "  cd \"$DEST\""
echo "  cmake --preset mingw && cmake --build --preset mingw   # doit compiler tel quel"
echo "  puis : coder le metier dans src/ExampleModule.* et adapter ModuleFactory / CMakeLists."
echo
echo "AVANT TOUT DEPLOIEMENT : attribuer un port."
echo "  Le projet genere porte le port provisoire 8901, jamais utilise en"
echo "  production. Deux endroits le portent : config/$LOWER.example.json"
echo "  et le defaut compile dans include/$LOWER/ServiceConfig.h."

# Suggere un port concret plutot que « choisis-en un » : lire le registre a
# l'oeil pour trouver un trou est justement ce qui met deux projets sur le meme
# numero. Best-effort : si le registre est introuvable (parc partiel), on
# retombe sur l'instruction generique.
SUGGESTED=""
PARC="$(cd "$ROOT/.." && pwd)"   # dossier contenant tous les projets du parc
for base in "$PARC/morfTools" "$PARC/morfTools_travail"; do
    if [ -f "$base/ecosystem.json" ]; then
        SUGGESTED="$(python3 "$base/scripts/ecosystem-check.py" "$base/.." "$base/ecosystem.json" next-port 2>/dev/null || true)"
        MANIFEST="$base/ecosystem.json"
        break
    fi
done

if [ -n "$SUGGESTED" ]; then
    echo "  Prochain port libre du bloc service : >>> $SUGGESTED <<<"
    echo "  1. Ajouter ce projet a 'ports.allocations' de $MANIFEST avec http=$SUGGESTED."
    echo "  2. Reporter $SUGGESTED dans config/$LOWER.example.json et ServiceConfig.h."
else
    echo "  1. Reserver un port libre du bloc 8787-8799 dans 'ports.allocations'"
    echo "     de morfTools/ecosystem.json (y ajouter aussi ce projet)."
    echo "  2. Le reporter dans les DEUX emplacements ci-dessus."
fi
echo "  3. Verifier avec : morfTools/doctor.sh"
echo "  'morf doctor' echoue tant que le registre et la configuration divergent,"
echo "  et refuse le port provisoire en production."
