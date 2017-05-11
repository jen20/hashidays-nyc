#!/usr/bin/env bash

set -o errexit
set -o pipefail

function currentRegion() {
    echo '{{ ec2region }}' | /usr/local/bin/gomplate
}

function tagValue() {
    local tagName=$1

    echo "{{ ec2tag \"${tagName}\" }}" | /usr/local/bin/gomplate
}

function renderTemplate() {
    local inPath=$1
    local outPath=$2

    /usr/local/bin/gomplate \
        --left-delim "[[" \
        --right-delim "]]" \
        --file "${inPath}" \
        --out "${outPath}"
}

function downloadTLSCertificates() {
    local outputPath=$1

    local bucketName
    local region

    bucketName=$(tagValue "consul:tls_kms_bucket")
    region=$(currentRegion)

    trap 'rm -f /tmp/consul-server.key.enc /tmp/consul-server.cert.enc' EXIT

    aws s3 cp "s3://${bucketName}/consul/server.cert.enc" "/tmp/consul-server.cert.enc"
    aws kms decrypt \
        --region "${region}" \
        --ciphertext-blob fileb:///tmp/consul-server.cert.enc \
        --query Plaintext \
        --output text | base64 --decode > "/secrets/server.cert"

    aws s3 cp "s3://${bucketName}/consul/server.key.enc" "/tmp/consul-server.key.enc"
    aws kms decrypt \
        --region "${region}" \
        --ciphertext-blob fileb:///tmp/consul-server.key.enc \
        --query Plaintext \
        --output text | base64 --decode > "/secrets/server.key"
}

function writeDNSMasqConfig() {
    echo 'server=/{{ ec2tag "consul:tld" }}/{{ ec2meta "local-ipv4" }}#8600' | \
        /usr/local/bin/gomplate --out "/etc/dnsmasq.d/10-consul"
}

writeDNSMasqConfig
downloadTLSCertificates
renderTemplate \
    "/usr/local/share/consul-bootstrap-aws/20-cluster.json.tmpl" \
    "/etc/consul/20-cluster.json"
