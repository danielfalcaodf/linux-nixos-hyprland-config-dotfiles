<div align="center">
  <img src="home/.config/fastfetch/logo_nixos.png" width="100">
  <h1>devdaniel — NixOS Homelab + Workstation</h1>
  <p>Configuração declarativa, modular e segura para NixOS com Hyprland, Docker, Caddy e acesso remoto open-source.</p>
</div>

---

## 📦 Estrutura do Repositório

```
flake.nix                              ← Ponto de entrada do flake
hosts/devdaniel/
  configuration.nix                   ← Config principal do host
  hardware-configuration.nix.example  ← Exemplo (o real é gitignored)
  hardware-configuration.nix          ← ⚠️ VOCÊ cria este (ver abaixo)
home/
  daniel.nix                          ← Home Manager (shell, git, apps)
modules/
  system/    nix-settings, bootloader, users, networking, firewall, ssh, services, printing
  desktop/   hyprland, audio, fonts
  dev/       packages
  homelab/   docker, caddy, dns-local
  remote-access/  rustdesk, xrdp-xfce, wayvnc
stacks/
  portainer/   docker-compose.yml + .env.example
  n8n/         docker-compose.yml + .env.example
  databases/   docker-compose.yml + .env.example
legacy/
  original-xnm1/  ← Configuração original do fork (usuário xnm) — apenas referência
```

---

## 🖥️ Host alvo

| Parâmetro | Valor |
|-----------|-------|
| Hostname | `devdaniel` |
| Usuário | `daniel` |
| Timezone | `America/Sao_Paulo` |
| Domínio local | `devdaniel.home.arpa` |
| Padrão de apps | `app.devdaniel.home.arpa` |

---

## 🚀 Como usar

### 1. Editar o repositório em outro PC

```bash
# Clone o repositório
git clone https://github.com/danielfalcaodf/linux-nixos-hyprland-config-dotfiles.git ~/repo
cd ~/repo

# Faça suas edições nos módulos desejados
# Ex: modules/homelab/caddy.nix para adicionar um novo app

# Veja o que mudou
git diff

# Commit e push
git add -A
git commit -m "feat: adicionar novo serviço no Caddy"
git push
```

### 2. Clonar no NixOS (primeiro uso)

```bash
# No NixOS alvo, como root ou usando sudo:
sudo nix-shell -p git

# Clone para o home do usuário
git clone https://github.com/danielfalcaodf/linux-nixos-hyprland-config-dotfiles.git ~/repo
cd ~/repo
```

### 3. Copiar o hardware-configuration.nix real

```bash
# O arquivo real foi gerado durante a instalação do NixOS.
# Copie-o para a pasta do host (este arquivo está no .gitignore):
sudo cp /etc/nixos/hardware-configuration.nix \
        ~/repo/hosts/devdaniel/hardware-configuration.nix

# Verifique se está correto
cat ~/repo/hosts/devdaniel/hardware-configuration.nix
# Compare com o exemplo se quiser entender a estrutura:
cat ~/repo/hosts/devdaniel/hardware-configuration.nix.example
```

### 4. Testar build (sem aplicar)

```bash
cd ~/repo

# Verifica se a configuração compila sem erros
sudo nixos-rebuild build --flake .#devdaniel
```

### 5. Aplicar a configuração

```bash
cd ~/repo

# Aplica a configuração (precisa de sudo)
sudo nixos-rebuild switch --flake .#devdaniel
```

> **Dica:** Crie um alias no fish para facilitar:
> ```fish
> alias nixswitch="sudo nixos-rebuild switch --flake ~/repo#devdaniel"
> ```
> (já configurado em `home/daniel.nix`)

### 6. Atualizar o repositório no NixOS

```bash
cd ~/repo
git pull
sudo nixos-rebuild switch --flake .#devdaniel
```

### 7. Fazer rollback

```bash
# Listar gerações disponíveis
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Voltar para a geração anterior
sudo nixos-rebuild switch --rollback

# Ou voltar para uma geração específica
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

### 8. Atualizar as dependências do flake (update)

```bash
cd ~/repo
nix flake update          # atualiza todos os inputs
# ou apenas um input:
nix flake update nixpkgs
git add flake.lock
git commit -m "chore: atualizar flake.lock"
```

---

## 🐋 Docker e Stacks

### Subir o Portainer

```bash
cd ~/repo/stacks/portainer
cp .env.example .env
# edite .env se necessário
docker compose up -d

# Acesse via navegador:
# https://portainer.devdaniel.home.arpa
```

### Subir o n8n

```bash
cd ~/repo/stacks/n8n
cp .env.example .env

# OBRIGATÓRIO: defina senhas fortes no .env
nano .env
# N8N_DB_PASSWORD=...
# N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

docker compose up -d

# Acesse: https://n8n.devdaniel.home.arpa
```

### Subir os bancos de dados

```bash
cd ~/repo/stacks/databases
cp .env.example .env

# OBRIGATÓRIO: defina senhas fortes no .env
nano .env

docker compose up -d

# Adminer (GUI web): https://adminer.devdaniel.home.arpa
# PostgreSQL: 127.0.0.1:5432
# MySQL:      127.0.0.1:3306
# SQL Server: 127.0.0.1:1433
```

> ⚠️ **Os bancos de dados ficam acessíveis apenas em `127.0.0.1`** — não são expostos para a rede local.

---

## 🌐 Adicionar novo app com subdomínio local

**Passo 1:** Adicione o virtual host no Caddy:

```nix
# modules/homelab/caddy.nix
virtualHosts."meuapp.devdaniel.home.arpa" = {
  extraConfig = ''
    tls internal
    reverse_proxy 127.0.0.1:PORTA_DO_APP
  '';
};
```

**Passo 2:** O DNS já resolve automaticamente — `*.devdaniel.home.arpa` aponta para `127.0.0.1` via dnsmasq (`modules/homelab/dns-local.nix`). Nenhuma configuração DNS adicional é necessária.

**Passo 3:** Aplique a configuração:

```bash
sudo nixos-rebuild switch --flake ~/repo#devdaniel
```

**Passo 4:** Acesse `https://meuapp.devdaniel.home.arpa` no navegador.

> 💡 **TLS interno:** Caddy gera uma CA local automaticamente. Para os navegadores confiarem:
> ```bash
> sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt \
>         /usr/local/share/ca-certificates/caddy-local.crt
> sudo update-ca-certificates
> ```
> Ou importe o `root.crt` diretamente no seu navegador.

---

## 🖥️ Acesso Remoto

### RustDesk (recomendado — open-source)

**Na máquina a ser acessada (devdaniel):**
```bash
# O cliente RustDesk já está instalado (modules/remote-access/rustdesk.nix)
# Abra o RustDesk e anote o ID da máquina
rustdesk
```

**Para usar servidor self-hosted:**

1. Descomente o bloco `services.rustdesk-server` em `modules/remote-access/rustdesk.nix`
2. Adicione as portas ao firewall em `modules/system/firewall.nix`:
   ```nix
   allowedTCPPorts = [ ... 21115 21116 21117 21118 21119 ];
   allowedUDPPorts = [ 21116 ];
   ```
3. Aplique: `sudo nixos-rebuild switch --flake ~/repo#devdaniel`
4. Configure os clientes RustDesk para usar o IP da máquina como servidor

**No PC cliente:**
- Baixe o RustDesk: https://rustdesk.com
- Use o ID mostrado na tela do servidor para conectar

---

### XRDP + XFCE (fallback RDP — para clientes Windows/Remmina)

**Habilitar:**

```nix
# hosts/devdaniel/configuration.nix
homelab.xrdp.enable = true;
```

```bash
sudo nixos-rebuild switch --flake ~/repo#devdaniel
```

**Conectar (Windows):**
- Abra "Conexão de Área de Trabalho Remota"
- Endereço: `devdaniel.local` ou IP da máquina
- Usuário: `daniel` | Senha: a definida com `passwd`

**Conectar (Linux com Remmina):**
```bash
remmina -c rdp://daniel@devdaniel.local
```

---

### WayVNC (VNC nativo Wayland — acessa sessão Hyprland existente)

**Habilitar:**

```nix
# hosts/devdaniel/configuration.nix
homelab.wayvnc.enable = true;
```

```bash
sudo nixos-rebuild switch --flake ~/repo#devdaniel
```

**Iniciar o servidor VNC (no devdaniel, com Hyprland rodando):**
```bash
# Via túnel SSH (recomendado — sem expor porta VNC)
wayvnc 127.0.0.1 5900

# Ou como serviço de usuário (habilitado pelo módulo):
systemctl --user enable --now wayvnc.service
```

**Acessar via túnel SSH seguro (do PC remoto):**
```bash
# 1. Abra o túnel SSH
ssh -L 5900:127.0.0.1:5900 daniel@devdaniel.local -N &

# 2. Conecte com qualquer cliente VNC
# Remmina:
remmina -c vnc://127.0.0.1:5900

# TigerVNC:
vncviewer 127.0.0.1:5900
```

> 🔒 **Segurança:** WayVNC em `127.0.0.1` + túnel SSH é a configuração mais segura.
> Evite expor a porta 5900 diretamente.

---

### RealVNC (alternativa proprietária — não é o padrão)

> ℹ️ RealVNC não está configurado neste repositório. A prioridade é sempre
> ferramentas open-source (RustDesk, WayVNC, XRDP/FreeRDP).
>
> Se precisar do RealVNC, instale manualmente e consulte:
> https://www.realvnc.com/en/connect/download/vnc/

---

## 🔑 SSH

```bash
# Conectar na máquina
ssh daniel@devdaniel.local
# ou pelo IP:
ssh daniel@192.168.x.x

# Adicionar sua chave pública (faça no servidor):
ssh-copy-id -i ~/.ssh/id_ed25519.pub daniel@devdaniel.local
# ou edite modules/system/users.nix e adicione a chave em:
# openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
```

---

## 🔒 Segurança

| Regra | Status |
|-------|--------|
| SSH sem senha | ✅ `PasswordAuthentication = false` |
| SSH sem root | ✅ `PermitRootLogin = "no"` |
| Secrets fora do repo | ✅ `.env` no `.gitignore` |
| Bancos apenas localhost | ✅ `127.0.0.1:PORT` |
| Serviços via Caddy TLS | ✅ `tls internal` |
| Hardware config gitignored | ✅ |

---

## 🏗️ Apps e portas

| App | URL | Porta interna |
|-----|-----|---------------|
| Portainer | https://portainer.devdaniel.home.arpa | 9000 |
| n8n | https://n8n.devdaniel.home.arpa | 5678 |
| Uptime Kuma | https://uptime.devdaniel.home.arpa | 3001 |
| Grafana | https://grafana.devdaniel.home.arpa | 3000 |
| Dashboard | https://home.devdaniel.home.arpa | 3100 |
| Adminer | https://adminer.devdaniel.home.arpa | 8080 |
| PostgreSQL | 127.0.0.1:5432 | — |
| MySQL | 127.0.0.1:3306 | — |
| SQL Server | 127.0.0.1:1433 | — |

---

## 📜 Licença

MIT — veja [LICENSE](LICENSE)
