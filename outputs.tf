output "kubeconfig" {
value = <<EOF

---
apiVersion: v1
kind: Config
preferences: {}
clusters:
  - cluster:
      certificate-authority-data: ${module.kubernetes-engine.ca_certificate}
      server: https://${module.kubernetes-engine.endpoint}
    name: ${module.kubernetes-engine.name}
contexts:
  - context:
      cluster: ${module.kubernetes-engine.name}
      user: ${module.kubernetes-engine.name}
    name: ${module.kubernetes-engine.name}
current-context: ${module.kubernetes-engine.name}
users:
  - name: ${module.kubernetes-engine.name}
    user:
      auth-provider:
        config:
          cmd-args: config config-helper --format=json
          cmd-path: gcloud
          expiry-key: '{.credential.token_expiry}'
          token-key: '{.credential.access_token}'
        name: gcp

EOF
}

output "endpoint" {
  value = "https://${module.kubernetes-engine.endpoint}"
}
