- Edge TLS termination is not supported by the chart yet.
- when TLS is enabled (and certs are provided through a certificate resource and mounted into concourse-web) the ingress does not target port 443 
- Providing external secrets for TLS is not implemented. They always map to concourse-web 
- Generally all secrets refer to concourse-web, which makes it rather complicated to provide external secret through secret providers such as azure key vault or sealed secrets.