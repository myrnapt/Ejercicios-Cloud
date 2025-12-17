#!/bin/bash

# Mueve las claves PEM a ~/.ssh/ y les pone permisos 400
for key in bastion.pem private-*.pem; do
    if [ -f "$key" ]; then
        mv "$key" ~/.ssh/
        chmod 400 ~/.ssh/"$key"
    fi
done

# Añade la configuración al ~/.ssh/config sin duplicar
config_file="ssh_config_per_connect.txt"
ssh_config="$HOME/.ssh/config"

if [ -f "$config_file" ]; then
    # Añade solo si la primera línea no está ya presente
    firstline=$(head -n 1 "$config_file")
    if ! grep -qF "$firstline" "$ssh_config" 2>/dev/null; then
        cat "$config_file" >> "$ssh_config"
        echo "Configuración SSH añadida a $ssh_config."
    else
        echo "La configuración SSH ya estaba presente, no duplico."
    fi
else
    echo "No existe $config_file."
fi