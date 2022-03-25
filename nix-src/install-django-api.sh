#!/usr/bin/env bash



STRING_RETURNED_FROM_GTIHUB="$(ssh -T -o ConnectTimeout=5 git@github.com 2>&1)"
BASE_TEXT_THAT_IF_SUCCESS_AUTHENTICATING="You've successfully authenticated, but GitHub does not provide shell access."

if ! echo "${STRING_RETURNED_FROM_GTIHUB}" | rg -q -F "${BASE_TEXT_THAT_IF_SUCCESS_AUTHENTICATING}"; then
  echo 'Aparentemente seu ssh não está configurado.'
  echo 'Teste com o comando: ''ssh -T git@github.com'
fi


FOLDER_TO_CLONE='income-back'

mkdir -m0755 "${FOLDER_TO_CLONE}"

nix flake clone git+ssh://git@github.com/imobanco/DjangoAPI.git --dest "${FOLDER_TO_CLONE}"

cd "${FOLDER_TO_CLONE}" || echo 'Por algum motivo não foi possível entrar na pasta '"${FOLDER_TO_CLONE}"

# Otimização para testes, dev atualmente tem os navegadores e os drivers.
# Deve ser removido antes de entrar o PR
git checkout feature/installation-with-nix

# Sempre fazer build?
CURRENT_DIR="$(pwd)"
nix develop .# --command bash -c 'cd '"${CURRENT_DIR}"' && make build && make up.logs'
