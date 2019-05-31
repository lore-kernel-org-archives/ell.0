Content-Type: multipart/mixed; boundary="===============7625102904547377747=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: ELL building broken for 32bit systems
Date: Fri, 31 May 2019 23:12:24 +0000
Message-ID: <fc26a7106113add0b4f635ea7db8ff4dc6750ef3.camel@intel.com>
In-Reply-To: <2eb55c84-b8cf-90f8-867b-07b47f70dda1@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7625102904547377747==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 2019-05-31 at 15:44 -0500, Denis Kenzior wrote:
> No, I meant what version of ell?  The issue comes from gcc9 which
> > > is =

> much more strict about checking strncpy use than before.  The problem
> is =

> that we used to use something like:
> =

> =



Damnit, that is my bad.  My VM version of the git repo was wedged,
and stuck on an early Apirl-2019 version of ELL. So, I am no longer
getting the build warning=3Derror for genl.c as of the (now) tip:

> commit 21306874a2318eb17cdd23ec1cb0ed1a193d5971 (HEAD -> master,
origin/master, origin/HEAD)
> Author: Tim Kourt <tim.a.kourt@linux.intel.com>
> Date:   Thu May 30 13:20:48 2019 -0700

There *are* now three unit test assertions happening which I didn't
notice before, although they are in an area that doesn't affect me
personally.

These failures happen on both 64 and 32 bit Fedora 30:

[ell]$ unit/test-pem
TEST: pem/invalid header/test 1
TEST: pem/invalid header/test 2
TEST: pem/empty
TEST: pem/empty label
TEST: pem/v1 MD5AndDES encrypted Private Key
test-pem: unit/test-pem.c:111: test_encrypted_pkey: Assertion `pkey1'
failed.
Aborted (core dumped)
[ell]$ unit/test-tls
Running sysctl kernel.keys.maxkeys=3D2000 is recommended
TEST: TLS 1.0 PRF
TEST: TLS 1.2 PRF with SHA256
TEST: TLS 1.2 PRF with SHA384
TEST: TLS 1.2 PRF with SHA512
TEST: Certificate chains
TEST: TLS connection no auth
test-tls: unit/test-tls.c:550: test_tls_with_ver: Assertion `auth_ok'
failed.
Aborted (core dumped)
[ell]$ unit/test-key
TEST: unsupported
TEST: user key
TEST: Diffie-Hellman 1
TEST: Diffie-Hellman 2
TEST: Diffie-Hellman 3
TEST: simple keyring
TEST: trusted keyring
TEST: trust chain
TEST: key crypto
test-key: unit/test-key.c:572: test_key_crypto: Assertion `privkey'
failed.
Aborted (core dumped)


--===============7625102904547377747==
Content-Type: application/x-pkcs7-signature
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

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
/2uO+36toXJIrkRSOXG2qYEzQI5kZ0sbLp1dcxHIXP6hMhpL7+m2bT6VgQIDAQABo4ICKTCCAiUw
HQYDVR0OBBYEFIZVvEpBGkcRsJgSGlrm4o7AsTA9MB8GA1UdIwQYMBaAFB5pKrTcKP5HGE4hCz+8
rBEv8Jj1MGUGA1UdHwReMFwwWqBYoFaGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkv
Q1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNybDCBnwYI
KwYBBQUHAQEEgZIwgY8waQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRv
cnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUy
MDRBLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29tLzALBgNVHQ8EBAMCB4Aw
PAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlngd69OZXwQwIB
ZAIBCTAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoEHDAaMAoG
CCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwQwYDVR0RBDwwOqAjBgorBgEEAYI3FAIDoBUME2JyaWFu
LmdpeEBpbnRlbC5jb22BE2JyaWFuLmdpeEBpbnRlbC5jb20wDQYJKoZIhvcNAQEFBQADggEBACuN
3bQTKWnPqjCfAI95E3JEdS7jc7y7fY2FiTcofo0hiDYjZ97kdpZo7BwqWvOcMEPWfst7YQyy4naa
uS8RvC2+BM8rYtvYj0uvUj/AbwZTnlQILUtyOykV3GzyauRwq6H3fPpZeOrMbbHSsJICjGvoAUQ1
aOiV1qgLYnlrTzis6UQx+7JjzYkmRajfnMR1NcD5rNa5n8CcmvwrhYxPptvyo9FKMw5Dtwri7DUs
7bl/ls14Ie8Sf8LLJBwGUOMWtDcEToMqjBZgPhC/6CBuI74UfFLbOt9tg6QMNFtbCy5H8HQUjq+P
tLltdkaAwpAE894tf9fUhD+oz7s/o6NV49IxggIXMIICEwIBATCBkDB5MQswCQYDVQQGEwJVUzEL
MAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJbnRlbCBDb3Jwb3Jh
dGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSA0QQITMwAAyrfo
9lLjvkm/BgAAAADKtzAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
hkiG9w0BCQUxDxcNMTkwNTMxMjMxMjIzWjAjBgkqhkiG9w0BCQQxFgQUm+0QID8JksbSGV71heW6
xol43O8wDQYJKoZIhvcNAQEBBQAEggEAj4Cs3/vhdnfwn1HNHMvua94e5CcBfuMqSMQBKrMcupIT
M0o8jZoixXzMB8eAp0c78mmqXK3LvtAQGf5kOzKgVBxCrveXcgsvBGCFTeLLj8zt4+fT6/jMf2+J
j5do0I4WiQzVshsw+PtyVDrfbgf7KMZSjGaoRG9Axqv64BYb9ysTveagiEShmJmTx9p1uJjEdnjZ
rmO4I8CODIr4L3VGDuOt07N4VlBIbsDVMnciw++PGpFI9yOkUOqyDrDT008wT3wG0mWjymn+NzLF
GjXszJzFkX0IB6uerQs9IQu5Lgh7D2aa9JG79xSAbXw4YUwjwie58APwhjHZ7V5mgbYoKQAAAAAA
AA==
--===============7625102904547377747==--

