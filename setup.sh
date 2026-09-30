#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

FOLDERS=(
    "skills"
    "agents"
    "commands"
    "hooks"
)

echo "========================================"
echo " Claude Code - Config Linker"
echo "========================================"
echo
echo "Repository: ${SCRIPT_DIR}"
echo "Claude:     ${CLAUDE_DIR}"
echo

mkdir -p "$CLAUDE_DIR"

# ------------------------------------------------------------
# Merge Claude folder -> repository
# ------------------------------------------------------------
merge_directory() {
    local source="$1"
    local destination="$2"

    echo
    echo "Copiando conteúdo:"
    echo "  Claude: ${source}"
    echo "  Repo:   ${destination}"
    echo

    mkdir -p "$destination"

    while IFS= read -r -d '' item; do
        local relative="${item#$source/}"
        local target="${destination}/${relative}"

        if [ -d "$item" ] && [ ! -L "$item" ]; then
            mkdir -p "$target"
            merge_directory "$item" "$target"

        elif [ -e "$target" ] || [ -L "$target" ]; then
            echo
            echo "CONFLITO:"
            echo "  Claude: $item"
            echo "  Repo:   $target"
            echo
            echo "  [C] Copiar Claude -> Repo"
            echo "  [A] Apagar arquivo do Claude"
            echo "  [S] Pular"
            echo "  [X] Cancelar"
            read -r -p "Escolha: " choice

            case "${choice,,}" in
                c)
                    rm -rf "$target"
                    cp -a "$item" "$target"
                    echo "  -> Copiado."
                    ;;
                a)
                    rm -rf "$item"
                    echo "  -> Apagado do Claude."
                    ;;
                s)
                    echo "  -> Pulado."
                    ;;
                x)
                    echo "Operação cancelada."
                    exit 1
                    ;;
                *)
                    echo "Opção inválida. Arquivo pulado."
                    ;;
            esac

        else
            mkdir -p "$(dirname "$target")"
            cp -a "$item" "$target"
            echo "  + ${relative}"
        fi

    done < <(find "$source" -mindepth 1 -maxdepth 1 -print0)
}

# ------------------------------------------------------------
# Process each folder
# ------------------------------------------------------------
for folder in "${FOLDERS[@]}"; do
    SOURCE="${SCRIPT_DIR}/${folder}"
    TARGET="${CLAUDE_DIR}/${folder}"

    echo
    echo "----------------------------------------"
    echo "Pasta: ${folder}"
    echo "----------------------------------------"

    if [ ! -d "$SOURCE" ]; then
        echo "SKIP: ${SOURCE} não existe."
        continue
    fi

    # Existing symbolic link -> always skip
    if [ -L "$TARGET" ]; then
        echo "SKIP: ${TARGET} já é um link simbólico."
        continue
    fi

    # Target doesn't exist -> create link
    if [ ! -e "$TARGET" ]; then
        ln -s "$SOURCE" "$TARGET"
        echo "OK: link criado."
        continue
    fi

    # Existing target is empty -> replace with symlink
    if [ -d "$TARGET" ] && [ -z "$(find "$TARGET" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
        rmdir "$TARGET"
        ln -s "$SOURCE" "$TARGET"
        echo "OK: pasta vazia substituída por link."
        continue
    fi

    echo
    echo "A pasta do Claude já possui conteúdo:"
    echo "  ${TARGET}"
    echo
    echo "[I] Ignorar esta pasta"
    echo "[S] Substituir pelo link (APAGA o conteúdo existente)"
    echo "[C] Copiar conteúdo do Claude -> Repo"
    echo "[X] Cancelar tudo"
    echo

    read -r -p "Escolha: " choice

    case "${choice,,}" in
        i)
            echo "SKIP: usuário escolheu ignorar."
            ;;

        s)
            echo
            echo "ATENÇÃO: isto irá apagar:"
            echo "  ${TARGET}"
            echo
            read -r -p "Digite 'SIM' para confirmar: " confirm

            if [ "$confirm" = "SIM" ]; then
                rm -rf "$TARGET"
                ln -s "$SOURCE" "$TARGET"
                echo "OK: substituído por link."
            else
                echo "SKIP: substituição cancelada."
            fi
            ;;

        c)
            merge_directory "$TARGET" "$SOURCE"

            echo
            echo "Removendo pasta original do Claude..."
            rm -rf "$TARGET"

            ln -s "$SOURCE" "$TARGET"
            echo "OK: conteúdo mesclado e link criado."
            ;;

        x)
            echo "Operação cancelada."
            exit 0
            ;;

        *)
            echo "Opção inválida. Pasta ignorada."
            ;;
    esac
done

echo
echo "========================================"
echo " Concluído"
echo "========================================"
