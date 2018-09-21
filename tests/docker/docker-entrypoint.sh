#!/bin/sh
set -e

printf "[defaults]\nroles_path=/etc/ansible/roles\n" > /ansible/ansible.cfg

test -z ${freeipa_3rdparty_sssd_packages} && echo "Missing environment variable: freeipa_3rdparty_sssd_packages" && exit 1
test -z ${freeipa_enable_server} && echo "Missing environment variable: freeipa_enable_server" && exit 1
test -z ${freeipa_from_sources} && echo "Missing environment variable: freeipa_from_sources" && exit 1
test -z ${freeipa_version} && echo "Missing environment variable: freeipa_version" && exit 1
test -z ${sssd_from_sources} && echo "Missing environment variable: sssd_from_sources" && exit 1
test -z ${sssd_version} && echo "Missing environment variable: sssd_version" && exit 1

test -z ${yml_file} && echo "Missing environment variable: yml_file" && exit 1

test "True" = "${sssd_from_sources}" && ansible-galaxy install timorunge.sssd

if [ ! -f /etc/ansible/lint.zip ]; then
  wget https://github.com/ansible/galaxy-lint-rules/archive/master.zip -O \
  /etc/ansible/lint.zip
  unzip /etc/ansible/lint.zip -d /etc/ansible/lint
fi

ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /etc/ansible/roles/${ansible_role}
ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /ansible/test.yml

ansible-playbook /ansible/${yml_file} \
  -i /ansible/inventory \
  --syntax-check \
  -e "{ freeipa_3rdparty_sssd_packages: ${freeipa_3rdparty_sssd_packages} }" \
  -e "{ freeipa_enable_server: ${freeipa_enable_server} }" \
  -e "{ freeipa_from_sources: ${freeipa_from_sources} }" \
  -e "{ freeipa_version: ${freeipa_version} }" \
  -e "{ sssd_from_sources: ${sssd_from_sources} }" \
  -e "{ sssd_version: ${sssd_version} }"

ansible-playbook /ansible/${yml_file} \
  -i /ansible/inventory \
  --connection=local \
  -e "{ freeipa_3rdparty_sssd_packages: ${freeipa_3rdparty_sssd_packages} }" \
  -e "{ freeipa_enable_server: ${freeipa_enable_server} }" \
  -e "{ freeipa_from_sources: ${freeipa_from_sources} }" \
  -e "{ freeipa_version: ${freeipa_version} }" \
  -e "{ sssd_from_sources: ${sssd_from_sources} }" \
  -e "{ sssd_version: ${sssd_version} }" \
  --become $(test -z ${travis} && echo "-vvvv")

ansible-playbook /ansible/${yml_file} \
  -i /ansible/inventory \
  --connection=local \
  -e "{ freeipa_3rdparty_sssd_packages: ${freeipa_3rdparty_sssd_packages} }" \
  -e "{ freeipa_enable_server: ${freeipa_enable_server} }" \
  -e "{ freeipa_from_sources: ${freeipa_from_sources} }" \
  -e "{ freeipa_version: ${freeipa_version} }" \
  -e "{ sssd_from_sources: ${sssd_from_sources} }" \
  -e "{ sssd_version: ${sssd_version} }" \
  --become | \
  grep -q "changed=0.*failed=0" && \
  (echo "Idempotence test: pass" && exit 0) || \
  (echo "Idempotence test: fail" && exit 1)

if [ "True" = "${freeipa_from_sources}" ] && [ "True" = "${freeipa_enable_server}" ] ; then
  real_freeipa_version=$(ipa --version | awk '{print $2}' | tr -d "," 2>&1)
  test "${real_freeipa_version}" = "${freeipa_version}" && \
    (echo "FreeIPA version test: pass" && exit 0) || \
    (echo "FreeIPA version test: fail" && exit 1)
fi
