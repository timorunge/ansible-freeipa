#!/bin/sh
set -e

test -z ${YML_TEST_FILE} && echo 'Missing environment variable: YML_TEST_FILE' && exit 1

printf '[defaults]\nroles_path=/etc/ansible/roles' > ${ENV_WORKDIR}/ansible.cfg
test "${SSSD_REQUIRED}" = "yes-sir" && ansible-galaxy install timorunge.sssd
test "${ENABLE_SERVER}" = "nope" && sed -i 's/freeipa_enable_server: true/freeipa_enable_server: false/g' ${ENV_WORKDIR}/${YML_TEST_FILE}

ansible-lint /etc/ansible/roles/${ENV_ROLE_NAME}/tasks/main.yml
ansible-playbook ${ENV_WORKDIR}/${YML_TEST_FILE} -i ${ENV_WORKDIR}/inventory --syntax-check
ansible-playbook ${ENV_WORKDIR}/${YML_TEST_FILE} -i ${ENV_WORKDIR}/inventory --connection=local --become $(test -z ${TRAVIS} && echo '-vvvv')
ansible-playbook ${ENV_WORKDIR}/${YML_TEST_FILE} -i ${ENV_WORKDIR}/inventory --connection=local --become | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
REAL_FREEIPA_VERSION=$(ipa --version | awk '{print $2}' | tr -d "," 2>&1)
EXPECTED_FREEIPA_VERSION=$(awk '/freeipa_version/{print $2}' ${ENV_WORKDIR}/${YML_TEST_FILE})
test "${REAL_FREEIPA_VERSION}" = "${EXPECTED_FREEIPA_VERSION}" && (echo 'FreeIPA version test: pass' && exit 0) || (echo 'FreeIPA version test: fail' && exit 1)
