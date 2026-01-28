Use Below line is Powershell to check

Test TLS 1.0 (should FAIL)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls
Invoke-WebRequest https://<domainname> -UseBasicParsing

Test TLS 1.1 (should FAIL)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls11
Invoke-WebRequest https://<domainname> -UseBasicParsing

Test TLS 1.2 (should SUCCEED)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://<domainname> -UseBasicParsing

✅ Expected result

TLS 1.0 → ❌ error

TLS 1.1 → ❌ error

TLS 1.2 → ✅ response

This alone is strong evidence for scanners.
