Content-Type: multipart/mixed; boundary="===============9002328691423054628=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] unit: More KDF combinations in PEM private key test
Date: Thu, 17 Aug 2017 11:06:30 +0200
Message-ID: <20170817090631.27630-2-andrew.zaborowski@intel.com>
In-Reply-To: <20170817090631.27630-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9002328691423054628==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add new test key file using pbeWithSHA1AndDES-CBC and change the v2 test
key files to use a different KDF each.  The DES-encrypted file keeps
using SHA1 (KDF id field not present), DES-EDE3 file now uses SHA224,
AES128 file uses SHA256 and AES256 file uses SHA512.
---
 Makefile.am                          |  1 +
 unit/cert-client-key-sha1-des.pem    | 29 +++++++++++++++++++
 unit/cert-client-key-v2-aes128.pem   | 56 ++++++++++++++++++--------------=
----
 unit/cert-client-key-v2-aes256.pem   | 56 ++++++++++++++++++--------------=
----
 unit/cert-client-key-v2-des-ede3.pem | 56 ++++++++++++++++++--------------=
----
 unit/test-pem.c                      |  3 ++
 6 files changed, 117 insertions(+), 84 deletions(-)
 create mode 100644 unit/cert-client-key-sha1-des.pem

diff --git a/Makefile.am b/Makefile.am
index 533153b..4cff295 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -235,6 +235,7 @@ unit_test_data_files =3D unit/settings.test unit/cert-c=
a.pem \
 			unit/cert-client-key-pkcs8.pem \
 			unit/cert-server-key-pkcs8.pem \
 			unit/cert-client-key-md5-des.pem \
+			unit/cert-client-key-sha1-des.pem \
 			unit/cert-client-key-v2-aes128.pem \
 			unit/cert-client-key-v2-aes256.pem \
 			unit/cert-client-key-v2-des-ede3.pem \
diff --git a/unit/cert-client-key-sha1-des.pem b/unit/cert-client-key-sha1-=
des.pem
new file mode 100644
index 0000000..964babf
--- /dev/null
+++ b/unit/cert-client-key-sha1-des.pem
@@ -0,0 +1,29 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIE6TAbBgkqhkiG9w0BBQowDgQIws6WkWueLSECAggABIIEyFESgaMHNg90jtsf
+HyCGj0ERjbs1nZRihOctkZuEXqdJw3TzUeEW73vW5ElS3owPe2SvDS18sKgaPt48
+MNj17Djd1yfB+Du/Nab2W46l4Jp/rN1R/ayxeTebRnQGSAEwed/Weep50xdWKCjj
+JOuD+dcaVI7G2d9rcM7Gw9iBROy46/wV4irN9s9WV/WytsqOBHpLnqR67giHOtlF
+MW/x23/gKVlKdFGXphCdjiVtBXWuJEY4IxETAk6W1bkMuCorEvoYLKQMLdDRNr45
+KZeCV0JCkT/Ty8qkdQOdsmFlJuplSb/ku7ej861V4jtaaEQDOM/Vu7qwW+OS+uy7
+tIWdwPz69AfOWOMo8F94Fpszn6920q8Pmg0HqF7tR3x5hYgV9NtxdHlTNdNx9/1Y
+MV7GTRcVoeinVWDTTSC6E+YUkdoRH54IO8BOj+2PY91zJeAzYH6Gf2yhxsOJ71S+
+3hrYwW/ySYD3FG9n3wx4k05NS1GxISvI/oKveCNkBbneFyJUYG54+xKuhRICj64/
+rvDUPGWVcayxEgbWTxiAt6v8JG3BqEyONx/FT1mNdPbg0t3MGzYesxDPA6C2nyE7
+JGycCejuKk1m4eWUTK7y/YftRD4zhvk78vU7XDD+MkQ55xSdk2hBdDSbMHVMuPhS
+QmlVCocdM8h11XF9uz+ap25hKCESRF+jFc1wbIIt6ovatx4IQG8KwcDkoZiBUovt
+WiWVawnTtNsezF6J7Knig3WB3VGfUcZK7I+qPa4OJJ5F8AP7NvVuxR2j7ykCIqOD
+jJrE4m7sKS1jzAOwgta3FM2PH5CLH6b+ri3MJKST/GmUDhxnIq+0NP0nOwAthuLo
+m3AR8zw083PGoR9QUoUbqBkR7J6CHlGaU94ql9pKFteWza65FjC2LmvdSGHRgRri
+aMh7kD4fFK+oLOiQRHmiGBBG6XZREdbbJmFQDaf5oGfdr2K4shCBKSNuR2f2PbNL
+VuYjFUQm49vHJ2qSamuZ16w3KgOxsDtvvPY20PjsbJ2kEqWsFgNbR/THTWcFoFBy
+JuiA+WqMvVY6xq16XqcdzBo7dQBV5G3RUn4mJErp/xx6kEoxfuR4nPac0yqxi4CG
+0tzJ4PJ4nKGJQH465DbP/ooNYOOyY5O0ZLFOxExdhpKpGB+R4vtkae/OFviR/r4m
+n0ZA86idb8U6rw3Ei8GkTNxb8Yx6GH854VkitUHC/L7dtt7qIsdyY3URckN0yjDU
+hNSMut514hDfjSZwjwU7gUzTYdlA/uuofa9UEv84S+KBu+jh/qQsnf1+ncaDELS8
+l6OSxldZ0iV8Tbaxz9QICmZyYSI4NH2qOCnu6aV4mohyJSNFRmf+Fv4UTyanbzBL
+S8tdLp5pMZtre+yF3XHoLcHlej/LGV1UeUdoOI25HeIA5s8+Gi+2Fm6dgCrasmHL
+elhC8sOtTygv4m9KEbxUEJab+z2Tu7JtMsKrzn72GAWlZenkENziklxyRg7z6FAJ
+MUbsB8sHc9xKgE2nAUmIMy6ws+qfgFc3sEIG6QspNnSgkwF9WkF2QGFt3SMeudx5
+lrpY7JQaS+N6qhV+bR2hqUCZMZ4RLRh+GQEmkPZFHK8UNCkD0VbEVjhGbPYp0IF+
+zHs//uVJkfS0ZxWT+w=3D=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-aes128.pem b/unit/cert-client-key-v2-a=
es128.pem
index 01cf80d..c361b86 100644
--- a/unit/cert-client-key-v2-aes128.pem
+++ b/unit/cert-client-key-v2-aes128.pem
@@ -1,30 +1,30 @@
 -----BEGIN ENCRYPTED PRIVATE KEY-----
-MIIFHzBJBgkqhkiG9w0BBQ0wPDAbBgkqhkiG9w0BBQwwDgQIruvC4dfgwlMCAggA
-MB0GCWCGSAFlAwQBAgQQGE5EgJ6nZ5bHxZLAs90seQSCBNBZaeeYO7dFK8301zHn
-ESNjgFaiB11ipzPxjpdJ0+cuP3ljfO+6RD31zANbE7Cpn1NjlhdFVDe5zzK8/1fY
-FnWBbRF4+jYbIppjjwmGjzEEo2NO0kc022RkeIIX+EDWzi25+Vu6LFf5brCybElY
-ObT+kgRGE6mzCDGuUBWiiR+XinqOK9hcYmLo8RtyQ3bLq2aWRDSSQXcCY/Il52c7
-F0Ts6gx6NV5hNUYF5h2pEtS0Dl8Qa7zfFtnEYRuhbEj0WEK/MS+NdZZ30rV/6Qlb
-Voji1meigvXPgNp8/wZROlN6HSVmijE/PSejvhXbptd0VXlMUjloVKJwH3LK3nfo
-RoYKcVvHRslzWC5jXbsaM0TcOSE1JJJUG9ksnp0Ltv+tGw4OR1uCJGT6ZatTcIlt
-+bYqvbbJ/t9849SDI3g87uipGqNxPOmH77T8Wikb9x3VE6DzOlXSYRNjbRIKA3XE
-eyD8ow1/95/gpUni0YewZCAuYUTn77Agq19RUa5AWHymMtj1YPZeBqh0SIVvz8nB
-FQafJr+XK9npT/adDHlQsJ129Fo0RvW+S73rgSOSb3qb4jQgGmRrmkyRsDqtufk5
-3EzUfn/uPdjkUu/m6X2nL6Y88sWPraK8bK4paKFOCwpb6/UN6DXVcgx7AS+EMzUv
-4MK7v1U140GKftH8qkFqG+iWgJfjZaWNhZX/k3KGYKANII1Fb35DgPjk3X1w+S6h
-QvQPjPHznlMTtzg8z7lSAXLZ0Ws66EiAVkBLK5+5ZKCz87hDjwwLXtGs4qbFIhTJ
-eZ5ohKvTlyiDfR1hmpcSu7L3jDzs/A62Y9Pc1yqCOhlXgRrefkqybPp1svXxR/Ja
-GKsWkWhSzq2qAzBJXrZ44eTxI79oDUoGdzFg9RLL5B+fsdh/q/OlJ0z079TwCS05
-ccyAmmlDANX8wHbmO4cDZ+0XU/wrsV3+N7DAokqTnBrMFnX0nohaBpgSiExnSxm7
-nOVk9tAoiuIxcabRAgtwW9tEEUDpoI+o44YuIYKsTX/ku3CILOzZhRuqS+oy1/na
-1PvFIuStDYwhWk92NZBsce6+9c5tpPsHgA4mUzokWH6kQ8EeFiq4x11Ooeb5ND4Q
-Z8unqZlJug4LHMWW2Mjsv1dA7qSg+4bbN6RQ+VS89cfcBZAjpKmMnGroWmcLJQQo
-l2CBTzKRw8r0UOnp/EUca7eOUdX7sQhN9Ozmd1HPh6araDAKBnA9IdTWdZKtgefp
-/gsZJ6rgBgqwhQxilCl4lzHN3QGtcg/6fU6VV68IrgU4lD5iKwWDcRBXaCgks/E3
-5useAMJAIJR0qJ2RBnNcfl9QX2qlDqeZKa2CqLHwc4BrEx+QHi8r2bJL1ChRNH9F
-dRaKXPWLWh9vx4d6Xw/xWBMQ3PIEM5JN3oZonFKMfYnRU4ncGQjxoR8PWwr1UEcA
-iT0JqgHX3PnWvSR5DfIJJHGlKTWZlMwtOdgB1Q1eSuIkkkU8JJCuIts4T9juLr0U
-Nng85ZA58JqHpLvPLAecRdMB652lBu4V63XyobnbkQH6rxvF5dh/wi/YyJ3EQgc/
-Lvh068Dheyegbg7B2tDbKvf7Xvjkzmd1T4KZcF0P7iuyq9tzWfQl+8bYmRW+VsR3
-g3GTgMVXQFVQz0+jFSM3Q/JWPA=3D=3D
+MIIFLTBXBgkqhkiG9w0BBQ0wSjApBgkqhkiG9w0BBQwwHAQIaoB8gQvMA3MCAggA
+MAwGCCqGSIb3DQIJBQAwHQYJYIZIAWUDBAECBBDXGdDLgywuoMlkK3ndSRzpBIIE
+0Ou2yNDdZV4C/GqXSraYpbrkIg0Jr8yGYk9pnl5wrjfm3QHbKaev3so9L4jiy5K3
+nOY/DCmLFuAu739yML5iBKgoqJjqWP98IXPU+5sIPcz0hcyN62Z4Z0qDnv82yly0
+sJySnW5Jx0AfjqpbJAoUl3IsUgkiJvqy+G/o3O4Ovly7OnnfH2loACz7pEV2COnI
+daGjxYlW2KbIIixjtsMLavQdtSWvulSJekwUvYLUMqlnxzRmPiO5jKcFGxXXNZiY
+7UBytlGC8gJtIQ4XhsvIlpTMUMmXKT9Hl9xo1BtRvBMWZtzWfCzCsa0jTonl/1sx
+2Rr1fUOwTMuh/E7oGYFTrzGiJdkj2MaNbayDI9i8bbwkZQCswxKTIR1TjSw8YgPd
+pMv8ubxVJFS9pPLw8qVhehXTVrGzbL2Ivt7XWgDfh09CHc1Ny6TS2M9C+4Qb2ZHk
+wAdjHW1g9T15fzVMpZpKA6VP8s9wVq/AoRUTPkur/KaWIEynl+oma90RIOw1eucb
+2kPPLnEEbodi7AqTZuNFQDKQebAigN+DYlsRaEn7m+Xzc7qb1+j6UAsmyxOymOgO
+ZecHmUjOACZrvzivp/gQexFqnSnUJlcCi8/Tea0qd+iXLTaNr23WlXtkkePiH126
+rK6+vY0d4nV92oXyY9YxjWnNWLWbXDxXOo5D0iorY6Qszm7QMO/FFf4HtrPZeddT
+COns/9FSySIwuTN6iOBpWMTBySMu5Tl5KMbVqBSknpFdGK459OXhKd2v2FmEd7mC
+QfVRwLmL96QkOHOCjHTNWIASH5FACJhoGdGycd23zPRFEWrWPX2WrOg6ZUOY6+Uw
+1bSzCYTYbkbww2ki5mBgCA8dYpYr25qZKycCn43IHCMCKLNIEXfM9QznLBcyvQOS
+rpkwtr4szrGBc24wgWGPmR9FFacMYZ+qw0FprvkUChlLEMP0/8oS/2Rip22Xqqqa
+VrGkySuT93fuYm0GfJJ0wasccZ3ICfZZbxniGpU4G7Qf47KaySuGOjrZbT0rSlrx
+JUm8H500DkI63aCdDu93x6Bn4JZ8Nhb6ZH3l6asGDQnyE1BvEfVFpVMJuNk0eSQF
+dLzYLFrmYtfx1T1lkTyBEc5AK7vN8sM3Hhx9XaujJoX7Vv6XcS4txFd+CmSgim6A
+0/9kHVrASB+iAOe3Y91h/BY29C3H74pVN67TqTjVbG3zwrjTY0DuwzDnfiWoWQtc
+6vuYACmRmJT0BBDLawxrrXWe/o+quQvkZuwgFhvi4SdXLqoDGuS3ICBzbCERCXsK
+21dMjyG0lyY5zO+QNEC6Fm0WEKMbPAnAi40DuCFQHTg0aosX2+HNc8vETLHEMYN3
+20cVLFJ6L58MOcDGk4qPFIenL+HUQeKXVxusFPmqE2vXiaDF3N0/l+NJihm2iRAH
+YNScjCJLC+5hjcjApJVT7mg30CIlnd+Ds48iv9PSIDQxPKVPZ6COOiPUjD/9mUfu
+6beQuy+3H6JIY8hhNwf2G/g/fzCKJln9/2CI+TylkfbhIVlic8I+zJbD2FBo1mqx
+gLxjSJR4/A0AghKx064IxvMRR6u9hMjIGRZfyk2uaG8qEUzXQ5I4cCY4tyzOU+i1
+gLahPQH8nXzENPqhBcGaOEovunIH7iL0M//DrMV/X42F
 -----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-aes256.pem b/unit/cert-client-key-v2-a=
es256.pem
index cfca70c..a11858f 100644
--- a/unit/cert-client-key-v2-aes256.pem
+++ b/unit/cert-client-key-v2-aes256.pem
@@ -1,30 +1,30 @@
 -----BEGIN ENCRYPTED PRIVATE KEY-----
-MIIFHzBJBgkqhkiG9w0BBQ0wPDAbBgkqhkiG9w0BBQwwDgQIpk7ueupozNMCAggA
-MB0GCWCGSAFlAwQBKgQQSlv6z6I4xJfloAEAyx3F7ASCBNDpL021QN2prL3hlTjK
-qea2QZu9xwAxQljKRL00T7i6VcDOJ//YwOgc83GHYjNf47bTIYmzuYvDta6zV82D
-huOMERS3Ep/bIWAf8Jd0bR1vbrvWcDI285083EFbh9PZqnUrFRPdJiqBu/VgyqiE
-2UNjK1s8l8SERVbOSTRNs1glHpUztuvrUxgDsvUqDrFDs8HIfRlOriI2NFIW5kPb
-ncSl5yrUlzerZWmXgF5KCKOh/ojyV56v4UUWaiFzAL7GBxLnYR4EaW3p8xKP/Adq
-vZMkAHX7YzMi9NEWVPmGVLPxkFC50d8XVOOaeI9nt6LAdsnba4xjLvih5dvtIUGc
-LrIgRrc+7l1r+/bZjpFOov4+jTX11cW0HCkm5G6ewuxp57t2XM3cZYk0gGsixGNd
-r3IdWIqCby2vbeI3bdoQpGQkheZmDZ9YUsaTm+qQVtP6bQgiuPLTroP4FISgXTAw
-9OAx9pCyqYMev4QQr9s/a/8kvjVlG6qx4PXLgt8pacW+1Sws7oa8PtfDfVqihqou
-jS91JxLh2xtWsaTepzpsyrMw9g3YjtnO0nkweFvG55Aie1uEkS0hzX7jJ1ITWxvN
-0g8lUNrG1oQeErD/V2bSgtK4r4eaF0RYM/DlR266fVQmKIydnuHzl7Yfdcq5doVg
-416FpzqHVPoPbeg8p9KgcveSGqkAHF0CtemipPu3pVoITvSgGmM6Q60hOk68Wsog
-WxqgT0/pq4W0A0nMwPnP5ecyCBxOZFcgHhgdoPELf1zwUiC6PrxrJaViKaD2tpHk
-IGugw/tBQKvDpQYg7eJyCtCS2bCsvh5FPPCm40Cre2AovidIhjHJ1J9FtlVBJZjG
-JHfF+dgiqKv4mdKyiTaUCiIdJeOvKh1wQTTY3fnyidPiVxL9/Yn/CmNsahrfE8Xe
-a8Le4g6eJk0PeuyhIv698JJFVcV5BVTkQL2YRIgEDrD/HSTm+XygAh+DTQiZrt3S
-i9CBWIU+ysE48soO7sD9iKGcQb3uJC6/l7dIaMW31erxpssXtfWeErtLFXnu7h8J
-SrP5Z5pYcC0ujimNGED1vFlFy5lQOWz3R6gWe44OJeqD3QKO4cthc9yafw/NmtZL
-WU+A7/NO86UK12+IErtDYgAkxZ0RkAb/H8lqWXseL+pnugw2ortLdhJ1PxosKGgq
-aPvfksyNKWKkspJ/9xpAgLoEjcClloExcymOCffpIE71UNhs09WUBIASxe5vIyaU
-61uklltTr2NNds7Sz1P6rwJNqQK2ExTWL3zQkm7xSdfwGBmPbducOjJXiQ1GJs5E
-IR3TJ3Z0fP18YqIMHXxJqt5iEozirtH2Z39xGLidOCNIK/oFiQIAwbRJX6GLDtBE
-QXnhrtzmnU1gzNzpLHpJkNys8v5uNqazlZYeTKCEXyF9xf75XhKpS5yObb5lUznT
-BQQ1SFct8/3JLdgke6lml/PdjL0T1Q98T8mKXAi0BMg0/41lbsuYMqEYpkgFQfYl
-7RsW7w7djVEOKpZOglBWVFUBOHYVyZru4ISzrp5KZxTvtLn8Avqi7gbNV7jZ0XqN
-C7uvJLPB3wyM17KAyW5iNldjXEpkwfle6txMxabmrAJiVBqs8VPagWtz2G5Sfhuc
-N7Om2aewyGHSTP+FVKJo5Zg94Q=3D=3D
+MIIFLTBXBgkqhkiG9w0BBQ0wSjApBgkqhkiG9w0BBQwwHAQIrrlN4qkLEiYCAggA
+MAwGCCqGSIb3DQILBQAwHQYJYIZIAWUDBAEqBBCAjMF+kCYUTLJ0ZtgGCTlRBIIE
+0HkItwXK+ojHuHF4HwNAf9Ufn+eSwj26oZxB+Wfbukq4VCw3NII7zIfXAHwgsuHd
+XP1+UTgCuqXFNf6DwS5dQe+htAzZUsKux3YlphVUvHfFxJBULve3/j05Fb6ts3cL
+9FXGmQpiurPJYn9TN1dhWrY1D1k8MMwkjee2cSXypm4Rlj4tVF8jGpLveg4cWFpN
+Hna1SYyVa7CBLGXI3FHVDtrLx6SkkYdH1rrzgwSoTdL7G1s/GLahoZ7wyiMytBDW
+06t1hnPNzoYvEwQTcoLcRZEa+b612lrH4As2qFOBb7COIJQ2p5VJxGeCI8EujVrU
+him6PCelSZjohn1gY72Y79BtO8EivjgXdYpxd1qp4A0iBEbeXIojsE3rcC6xDLdy
+b7adgM61ciR/ixoc9xvVGD4TwHAHZZldHkWk3jhN9mcA7PHWo5esMSIa7rL44p3v
+msOWUzoAdxykc4VIbFPtozOsz4ONNKd6H4S9Lbv2/J5MfA261wxbfzFHi3SnowC9
+4H61yXRjKm69C6qtpm3SkmeZHxA9KnsVA2YFE8XBQZPldin1YCCp3WcLF1Vdq7wX
+/2Dzns+g8PxyTEzyDOh5CB5VSreiVFH4Z/l+6cjCD0HN4cq1/99ntKLEd47ZKCGq
+jTAEO7eQQmTJdy6Mxyy2yeL6zI4/crzmfeSpFMavS7l6ujj1WUtFy2yb/FeiRca0
+63+GCr0Po9WNbe+j6Oh6vPRpKMHgGATsPX9Nn6hG+d5TCJ2ksDuowtnjMsEnZhZe
+PwL2iWXfZTIwaReaWh79HIBIRCURjn9pdKf+Q74gwG/S8CowGTxMJwnTZxf+o/+r
++2+xMG28fEEFhUUtn0yHQuDwzHwBv9NC9kH1bCtzP3a3jFqcF7plv4qBVOTmwOxX
+ScnyC9YUO786A+LWWzK9INbhDDP9GUIjFAFjKJYy0IKgjYH8WGfUfQXBjN0Dt14Y
+gZZJapP36/K+JxRPtgh/ZsB7dPqsGH6BH1oPD2cMQ5up2MlHvzUJq5iSZm8zDLMW
+ipaTt8DCaMc+97CuBis7539gP83JxyCLzZQxhyiKfWSuztiTiR1AcP95c8T3QebX
+Xf1LkmXDZK+aQiqtl0EqDikNIP8iIz+vwd4ba5bQ9eSUq2LwL6Q0h1UR/7EgOZHv
+b4ZY+kVqFRtesIyJnH0ULdZ4bWtNJwFItDmGvZry2x+t7BFSB4QCvUdmJl9I6y+9
++2Z69TaQEOQg7JFC3qBIzuKQ+ujpJtE5Tr5ICPfttpP/3zzf35eqFd7OsqQ+6iPw
+xWMYYo7yJKtveJwu4ko/nxNtblmPFhnMH3tfjwDdd4xZ8z/la3N0KOpQyNspyLuL
+b63GrhK5PGSG5DR5cPSfBjJ+TqAA8Qn/HG6mM+gBZo+D1T3918BteH92xIxamNd0
+xJQOXhwYTYgVXLGGRIY66967KseVqvgw8zirJ+y1idbOI0ENX/ctVAf1KE1LHFFs
+RjeuaCdeo3S40zblioxt3t27WhWuAKIuEBhL0zZozsMxWByU581eC0YvpWP3OLtV
+nx1l5A8ixg6w1OWyvoNwTuCK7HmCAZUIHcWNpGZzqxvJ+BaVhoRnsHoL3dvAeATu
+Z89Bfu14QFZxRZn0MZXo+XPpsSAR0WUUmBnChoaEAwtl
 -----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-des-ede3.pem b/unit/cert-client-key-v2=
-des-ede3.pem
index e94d345..9f3f549 100644
--- a/unit/cert-client-key-v2-des-ede3.pem
+++ b/unit/cert-client-key-v2-des-ede3.pem
@@ -1,30 +1,30 @@
 -----BEGIN ENCRYPTED PRIVATE KEY-----
-MIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDgQIVG6rLrQ+fVgCAggA
-MBQGCCqGSIb3DQMHBAizDQ76m4Q4ZQSCBMh50R/dRYR4agewBCpNNVYIHV/wotfZ
-PhhwcJQFZMmp50rCI9rh13w8TSr+KDreXTY+XzvqFS7fbB0JV3QWlv2wvqkAFXoJ
-CYlE40WXg5Qd2H849IyLEil8J5mvoZohDZYNk82zi+PSvkvxJ8d1RJIiHHhmReeC
-0+rDHd9C+Xr2MVBOMA+gimx/P3qtS4jI0qjmzyUiorHa9lvY5qzxbMibi4mEAjBy
-VWviWHszpCwKVapODFlG2r5R2wvmhp4GUGSigi7KtL7hijEbsh4CW2RqYLR733Nx
-WdsyIc4sD3908ttfQSmsSt6vchAMkelwFizGSEFLMsCne3MGjVsLpVitg6nswl6N
-pvngZu0zaggWFVPRIt+vIimeHrujzoiUuzDizjOVzCiyRkrFuJEMwN3l/AaSxUiG
-lOWga1Eb+McH3oJNU1WtrL7gDwfmKFc26D7xNMnGLcdYxfM1F98XfM3FVswaHdC7
-0uTmEmMdhpoNw4CWai37NpigW01cDnxMMpFuX0yTU8GUU/JkBgZ4NHE1sTZrFiOf
-mMr83waumMGwwChhZAd1qDRB35c1HLvVqBt3HkdcyCZP1JBxG4QLrw7IVzG+knlj
-QdrBC/lDNA15wG27v5hRUVEoeFRJkOllUlSqfh0PmJw2t32BP8dS6EsM8eTpnQ7R
-ysqO5CVZ3WTNFwIZ7wD8zmaBOamkZ1OzOluYFL5sBHGRM05pSEsYOivsi7tlp5Gj
-ZQjR+qSKLT34R4QxWhziWgNC/ynjVuWNWX67p1T/ngsM9kGa6cm84XbHQL7CqUyX
-H7vOWtWHGCclS1Ori5vjFP8/qdOVGMpiKnX8HvoBv6zxJvfMYNAz39MMewlfHdCa
-vEvBVwxLYRxbaL1IGNUebXVyn7JNRhuDm1SDNU1ADj8GW4AL5+22D9xArz8Lnkrj
-+lvHm1NMIckciFYHraKmIPeJLiLIxDJ1SX+WgJGLo+P0W2TJLHAnQl5a1KzJOsIq
-/y35Q4mFLX0JE4mzAj2S1bsVate4FZpnKqVT0mfN5/UPSnQOpJKRSTYV9QJm1mGb
-gtdvwSvSniyjSSP/MAB+M7C0N4syC4N4sXYXJTKcM3CN/tN4ASycpkWRvXXLWRsj
-BuQq9z50ojdnx+twu2eG3eYRAGjEW7yOD3GHPQOtCx3IQDptmzYf2v4rk9x+IFfT
-L0ZfmyVevXgm9zjHI9s64Ok1g/6SL8lO+wszfjDs1zEgrMRfoVoKOBrWN7fYKiKi
-GBUeaZ9HgcM1ha/a63N1LPK9OPR2w4qh+DpCLpfvhzZN6IRv1oFddws8jwye1pJb
-1Po33NxHUfsOTX+lpc61NOEua7s3/Wu5gm0jBrX5c/aKCfXMsJHzW+0wl4SAXDog
-3Cl29/NAMSQDpQP9A91QSwHYkyzk4rBLcrbx6bQfFSHOqdl2dto+UJfiz+5PzD7s
-I7k72LGzrfIOq4brLbrLIGwj/ani/vvSZnXYzx3uUeP9w1EZSgNKC9HLBW7lyav3
-IlY7HAO2GMVlIdzynHPT3wMXtLqf/ykO+tkrEF4LjOu9r+cdhCxHum22vlgZKL7J
-J044ViKBro0CWL1wajpFQOvG/BG4VDJ/dfGee0iBr4R+CIkaUwVTCdRsibyZRM8E
-FL0=3D
+MIIFHDBOBgkqhkiG9w0BBQ0wQTApBgkqhkiG9w0BBQwwHAQI9rCTx3WR3q4CAggA
+MAwGCCqGSIb3DQIIBQAwFAYIKoZIhvcNAwcECE5PoWcRbClfBIIEyK5/OPGPPDAr
+cdtrEgJLBIy1U65JNtLvwJ3SEk5MYwTH0oXR98JSxxvTd4xqoy8q3IjyM6pA1xFu
+Uqz0N7YyCEvj48GyuGdNIeYChaGD4vwhA/LB+at4NhE967h/cTgomF3gxIiHUYLD
+pcsCZS6iFXlsQ3BT7V7Fiz81Lb35v3tGXuCgaSFTTqOrThdyqe6sh3k3Rpsph31K
+dVGxKW2C57LcgqAXFc3fiYVf2jseXE8m79H75ldqUQITPEr6hDYCDkwoWzHQzl1d
+4bwYv45TNaHtBsR9386m67qyEc5suXlHl0AO5Dua/iPqynIHTe8P1jkGzPUAcWu9
+HyZ2e1ddrSBNf/AsGvteV7Sae4b5tmeBGKBrvalAkbXd/Pn+q1CsxE+6tjSeWAau
+K+jqbKt92QEpFRmBt+lXOgUOuCgXYMHzpk5j0gKhbfKk77+66YxTKeznIaw965Op
+kod8BC5KsJ4htPJzer6HB9QBBkMkNqOT6/VqDyj4muks4WH8lWqzGZjL3EmUzJI4
+VwVZWlA0LCQnLvTXIdKVK5I2GThq46cAuzpDS0W43EmdoTNuPhImNGbsUFq2kH+N
+s2IH44EiWJTXUJpi6uVkiigKYQWaMziVD5csTPJ07X6wqzaI26k96X8zdsCqatNz
+Otn1+s5KB30pyHygok+C9bFAjtNkcsJIxmFxIOwkOBEXAuRKsGbPYp23Euj9xz63
+b0lQap5WG0e5dnI+GWur8VcFgJLTNeLDtndcLOqvXShpO5b6XF/yPAmS3wkDsZeK
+XZePgikvX4Arp0lovkntxRx4kHl+bppH8JeH4Tlq3J4SMqWgOHFXBFU9JSa/fI82
+b+fukmeRd2UO4Vm/VBkv8OV6O2/wOeDg5I+0sGOE1N7J/dTiVwU94GcyLE1C1fho
+54hsbIBRL+5S6foiX/9xYnfubRrzOSb2Lm1NQBzzZQAY2BxAsrmb1vQwnZ9gg7g8
+HWo8aYs5M7A0aMKLOkoOHXvUXx61tSR6oYQD9WF9lBKPaDXA1BdU24PF0m5ov872
+0nCGf/ScsHluLhSOt0vy422105XJGrG/OUJFj7onAW3JpKP0/HEEJcTMiNX+61nr
+RtA1IPZdosznorcrDMdHgG/5uwQJITjEzybd12jbTeJqxhZszGI4f1BjDVdAt6vT
+csztYrp5oLSo/O4A5RQUgAL3C4WIKQB6+7NBEl/uqmofp2jAiQZyLDq/XI9IB5OG
+kB+dXhdPtaG6eqMwCZQTRHethF0XhZEmdeylxYJ4GJikfo6n50r7F0uv97lzbhsA
+C3AbHkxRnZ1sC36Rndn0nh7VyFCsNbuqEj9k9kJrdvWw/WJ4UsjDAboKN1KQrG2n
+fh4pHqq+tXhdgPiq/VB1Xf33RrsVrEheNZCjtPbCGkLV4eW6nL4bkN+b/jNvH7m6
+yrmzPIujn7zovrYgowoCc6zk81GOrMWVt7hKzYQG10yO0vp5g4hFDpbue30k/3/m
+A6YcqdZIxzTchO+LRG0sXEyq3iqVYVbsuGpCrVJNLPnbKeI80C/fblVfJjNrK2CE
+OoUKcqHaVhnKqB/0zQGA1hY3SffPjCuFLLhy30GX8WVbKssZA4Ekh2cqqElWZahP
+IW+TZvQEN/pzrdvUab9qsQ=3D=3D
 -----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/test-pem.c b/unit/test-pem.c
index 9090a24..79a7498 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -137,6 +137,9 @@ int main(int argc, char *argv[])
 	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
 			test_encrypted_pkey,
 			"unit/cert-client-key-md5-des.pem");
+	l_test_add("pem/v1 SHA1AndDES encrypted Private Key",
+			test_encrypted_pkey,
+			"unit/cert-client-key-sha1-des.pem");
 	l_test_add("pem/v2 DES encrypted Private Key", test_encrypted_pkey,
 			"unit/cert-client-key-v2-des.pem");
 	l_test_add("pem/v2 DES EDE3 encrypted Private Key", test_encrypted_pkey,
-- =

2.11.0


--===============9002328691423054628==--

