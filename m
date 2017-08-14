Content-Type: multipart/mixed; boundary="===============4137665560162417927=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/7] unit: Test loading encrypted private key PEM files
Date: Mon, 14 Aug 2017 16:57:50 +0200
Message-ID: <20170814145750.6683-7-andrew.zaborowski@intel.com>
In-Reply-To: <20170814145750.6683-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4137665560162417927==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

New test cert files are encrytped versions of cert-client-key-pkcs8.pem
generated with:

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-md5-des.pe=
m -topk8

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des.pem=
 -topk8 -v2 des-cbc

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-des-ede=
3.pem -topk8 -v2 des-ede3-cbc

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes128.=
pem -topk8 -v2 aes128

openssl pkcs8 -in cert-client-key-pkcs8.pem -out cert-client-key-v2-aes256.=
pem -topk8 -v2 aes256
---
 Makefile.am                          |  5 ++++
 unit/cert-client-key-md5-des.pem     | 29 ++++++++++++++++++++++
 unit/cert-client-key-v2-aes128.pem   | 30 ++++++++++++++++++++++
 unit/cert-client-key-v2-aes256.pem   | 30 ++++++++++++++++++++++
 unit/cert-client-key-v2-des-ede3.pem | 30 ++++++++++++++++++++++
 unit/cert-client-key-v2-des.pem      | 29 ++++++++++++++++++++++
 unit/test-pem.c                      | 48 ++++++++++++++++++++++++++++++++=
++++
 7 files changed, 201 insertions(+)
 create mode 100644 unit/cert-client-key-md5-des.pem
 create mode 100644 unit/cert-client-key-v2-aes128.pem
 create mode 100644 unit/cert-client-key-v2-aes256.pem
 create mode 100644 unit/cert-client-key-v2-des-ede3.pem
 create mode 100644 unit/cert-client-key-v2-des.pem

diff --git a/Makefile.am b/Makefile.am
index 9f7183c..533153b 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -234,6 +234,11 @@ unit_test_data_files =3D unit/settings.test unit/cert-=
ca.pem \
 			unit/cert-intca.pem unit/cert-entity-int.pem \
 			unit/cert-client-key-pkcs8.pem \
 			unit/cert-server-key-pkcs8.pem \
+			unit/cert-client-key-md5-des.pem \
+			unit/cert-client-key-v2-aes128.pem \
+			unit/cert-client-key-v2-aes256.pem \
+			unit/cert-client-key-v2-des-ede3.pem \
+			unit/cert-client-key-v2-des.pem \
 			unit/dbus.conf
 =

 examples =3D examples/dbus-service examples/https-client-test \
diff --git a/unit/cert-client-key-md5-des.pem b/unit/cert-client-key-md5-de=
s.pem
new file mode 100644
index 0000000..e3edfc5
--- /dev/null
+++ b/unit/cert-client-key-md5-des.pem
@@ -0,0 +1,29 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIE6TAbBgkqhkiG9w0BBQMwDgQI4Jws4ZHp7oQCAggABIIEyGImScBCorOX2u/F
+ISGvMBLavYPfA1f349fcfPfjbMeTLtrubuFfSYJDrB1KaP4oWsK3RA8AjuNtP49N
+fWjaAD6E9YTcNPVODgqNaoeslatqszPEqsqfx+vz1inTc+dyZ8ZYTWDlWAFSC33B
+k6z5CX68YdujTI9hBtkwAJuCoSSIKJNM7duSXzlxM3IfCfzRn4BuO+8usdxqrc5A
+p1R+LvDehIeOrQxkpJE3oHPq1xcCG4/WOnHWwRlmHmQIc2Z+ZLdgFjXYLvmNG58B
+PcBAxWjppmZZMXiMqIoZxqQ7hBhwqI2wxCFYAihf4cgn6bT37sv0CeNPjRHfftpr
+3tWgSeqLbov7Sfm5f1tq3AhJ3om8aaHEL8vUexs0j9mKhJyM0gyel+d1pHSi9/Ka
+U/qNk2KzhZl4+/p7ngjkK8or7IDgbRQWzRXac6uxnvhDRuCZWWAjgzq7A9KdjMCf
+T0+OX9USpOl2/cQSeKdRY5xKLBudQGilMvKZwd+rxBMkDBCwl+fj5HX1Tcj085kv
+CSEOpA90HvqI9VvdxPw0KKWTc/d3FgWKVVzEqtVUCbtDGXZnv3Kt9F05zoX/wL2k
+PkCd7yQouCYxPevVVz1kus5mwWHaZbEUW6S9GUSeZXs/Itb9Jwl9X6m1G9e393U+
+FQb95dfDzP1zQzemLJ+Iu6rkmKNC6x1pC+hNG3jy5QRoQ9wB4WV4q3JRHFUECEgd
+CAN52Saz9f7qt1MmoNPM0fSS+ovh08KoABEI7mp8s9fFj0b7x9h/zlRgigNKp+JE
+N9/51OSopajlse0ly+1zb8I2iOGeA3U4cvZG5mEP+kstJvdD4PYgx9cWDm6EDKmN
+4nIL48aNoWFxa7MGJsmQo56QmGAxG7lZusVu4lYUvHQsmqDQWhqBz1k/f4GzioN0
+7wslyuElIrZyRugYdh+Epy7WbXRi9nBhwuWpOx8TnwOszWIfJT7NLWH+/SaVzuG4
+IsR1gnaQ5HLPyXxuaJkzcZs7EOG5S5MT7tDW9i72RZUiUPGztmhOLxkYrH/r3UCa
+8Agc1nYXs8VH9sV+LMMGdCVoY/RwJvZwf13fqnLcmIA4iI8cDf1beUVm1JvdgIL/
+5Pbxyh2sAzyk/DIFD6yCQUacBKkR3EAXPG9gm5jebjHOU+gxSt69e3jgA1BvuoS5
+S3xLePrZnGZuPjM2PQX6LW1wWBtNlhbqWAkyeL3YwEwv2FjluFqALB/He/MaNly3
+UXFULImo8C/2UF9y9hgoSuamFqlKtgaNBUlqNPxX0EQmyCuqBEGYaouZ2TzPfZ44
+Jf6p6sQZeEmklEIDkaC9DvAGU7DPRfxolLpYHvdHQTwnjKMbFkg7FSAzzdNiKKeR
+nEnCkaofA2FASfQaZvOkewACaZfqJ1FCSsoetYq2Ulf8o1f8j/QM+JIq4p0DIybz
+4gsBmg05xufNiZNqZrrFc0/HcZkT3ahgtY+TMzU8d0hAS7roFNlM2lpaE69HJeTZ
+rhRO7/VAU2Kb0bQI5UWe4yfvbPBmmaxw06lPahlBAEgqeULwfVWBPafjSyq8vPag
+9RzpwSASqL6dv89qdOPE0JioA9xZ3cemlVOgqzd04AkdnDf3flGCJa6O9BujGm72
+8t0TmXLstK7YNaxQYA=3D=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-aes128.pem b/unit/cert-client-key-v2-a=
es128.pem
new file mode 100644
index 0000000..01cf80d
--- /dev/null
+++ b/unit/cert-client-key-v2-aes128.pem
@@ -0,0 +1,30 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIFHzBJBgkqhkiG9w0BBQ0wPDAbBgkqhkiG9w0BBQwwDgQIruvC4dfgwlMCAggA
+MB0GCWCGSAFlAwQBAgQQGE5EgJ6nZ5bHxZLAs90seQSCBNBZaeeYO7dFK8301zHn
+ESNjgFaiB11ipzPxjpdJ0+cuP3ljfO+6RD31zANbE7Cpn1NjlhdFVDe5zzK8/1fY
+FnWBbRF4+jYbIppjjwmGjzEEo2NO0kc022RkeIIX+EDWzi25+Vu6LFf5brCybElY
+ObT+kgRGE6mzCDGuUBWiiR+XinqOK9hcYmLo8RtyQ3bLq2aWRDSSQXcCY/Il52c7
+F0Ts6gx6NV5hNUYF5h2pEtS0Dl8Qa7zfFtnEYRuhbEj0WEK/MS+NdZZ30rV/6Qlb
+Voji1meigvXPgNp8/wZROlN6HSVmijE/PSejvhXbptd0VXlMUjloVKJwH3LK3nfo
+RoYKcVvHRslzWC5jXbsaM0TcOSE1JJJUG9ksnp0Ltv+tGw4OR1uCJGT6ZatTcIlt
++bYqvbbJ/t9849SDI3g87uipGqNxPOmH77T8Wikb9x3VE6DzOlXSYRNjbRIKA3XE
+eyD8ow1/95/gpUni0YewZCAuYUTn77Agq19RUa5AWHymMtj1YPZeBqh0SIVvz8nB
+FQafJr+XK9npT/adDHlQsJ129Fo0RvW+S73rgSOSb3qb4jQgGmRrmkyRsDqtufk5
+3EzUfn/uPdjkUu/m6X2nL6Y88sWPraK8bK4paKFOCwpb6/UN6DXVcgx7AS+EMzUv
+4MK7v1U140GKftH8qkFqG+iWgJfjZaWNhZX/k3KGYKANII1Fb35DgPjk3X1w+S6h
+QvQPjPHznlMTtzg8z7lSAXLZ0Ws66EiAVkBLK5+5ZKCz87hDjwwLXtGs4qbFIhTJ
+eZ5ohKvTlyiDfR1hmpcSu7L3jDzs/A62Y9Pc1yqCOhlXgRrefkqybPp1svXxR/Ja
+GKsWkWhSzq2qAzBJXrZ44eTxI79oDUoGdzFg9RLL5B+fsdh/q/OlJ0z079TwCS05
+ccyAmmlDANX8wHbmO4cDZ+0XU/wrsV3+N7DAokqTnBrMFnX0nohaBpgSiExnSxm7
+nOVk9tAoiuIxcabRAgtwW9tEEUDpoI+o44YuIYKsTX/ku3CILOzZhRuqS+oy1/na
+1PvFIuStDYwhWk92NZBsce6+9c5tpPsHgA4mUzokWH6kQ8EeFiq4x11Ooeb5ND4Q
+Z8unqZlJug4LHMWW2Mjsv1dA7qSg+4bbN6RQ+VS89cfcBZAjpKmMnGroWmcLJQQo
+l2CBTzKRw8r0UOnp/EUca7eOUdX7sQhN9Ozmd1HPh6araDAKBnA9IdTWdZKtgefp
+/gsZJ6rgBgqwhQxilCl4lzHN3QGtcg/6fU6VV68IrgU4lD5iKwWDcRBXaCgks/E3
+5useAMJAIJR0qJ2RBnNcfl9QX2qlDqeZKa2CqLHwc4BrEx+QHi8r2bJL1ChRNH9F
+dRaKXPWLWh9vx4d6Xw/xWBMQ3PIEM5JN3oZonFKMfYnRU4ncGQjxoR8PWwr1UEcA
+iT0JqgHX3PnWvSR5DfIJJHGlKTWZlMwtOdgB1Q1eSuIkkkU8JJCuIts4T9juLr0U
+Nng85ZA58JqHpLvPLAecRdMB652lBu4V63XyobnbkQH6rxvF5dh/wi/YyJ3EQgc/
+Lvh068Dheyegbg7B2tDbKvf7Xvjkzmd1T4KZcF0P7iuyq9tzWfQl+8bYmRW+VsR3
+g3GTgMVXQFVQz0+jFSM3Q/JWPA=3D=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-aes256.pem b/unit/cert-client-key-v2-a=
es256.pem
new file mode 100644
index 0000000..cfca70c
--- /dev/null
+++ b/unit/cert-client-key-v2-aes256.pem
@@ -0,0 +1,30 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIFHzBJBgkqhkiG9w0BBQ0wPDAbBgkqhkiG9w0BBQwwDgQIpk7ueupozNMCAggA
+MB0GCWCGSAFlAwQBKgQQSlv6z6I4xJfloAEAyx3F7ASCBNDpL021QN2prL3hlTjK
+qea2QZu9xwAxQljKRL00T7i6VcDOJ//YwOgc83GHYjNf47bTIYmzuYvDta6zV82D
+huOMERS3Ep/bIWAf8Jd0bR1vbrvWcDI285083EFbh9PZqnUrFRPdJiqBu/VgyqiE
+2UNjK1s8l8SERVbOSTRNs1glHpUztuvrUxgDsvUqDrFDs8HIfRlOriI2NFIW5kPb
+ncSl5yrUlzerZWmXgF5KCKOh/ojyV56v4UUWaiFzAL7GBxLnYR4EaW3p8xKP/Adq
+vZMkAHX7YzMi9NEWVPmGVLPxkFC50d8XVOOaeI9nt6LAdsnba4xjLvih5dvtIUGc
+LrIgRrc+7l1r+/bZjpFOov4+jTX11cW0HCkm5G6ewuxp57t2XM3cZYk0gGsixGNd
+r3IdWIqCby2vbeI3bdoQpGQkheZmDZ9YUsaTm+qQVtP6bQgiuPLTroP4FISgXTAw
+9OAx9pCyqYMev4QQr9s/a/8kvjVlG6qx4PXLgt8pacW+1Sws7oa8PtfDfVqihqou
+jS91JxLh2xtWsaTepzpsyrMw9g3YjtnO0nkweFvG55Aie1uEkS0hzX7jJ1ITWxvN
+0g8lUNrG1oQeErD/V2bSgtK4r4eaF0RYM/DlR266fVQmKIydnuHzl7Yfdcq5doVg
+416FpzqHVPoPbeg8p9KgcveSGqkAHF0CtemipPu3pVoITvSgGmM6Q60hOk68Wsog
+WxqgT0/pq4W0A0nMwPnP5ecyCBxOZFcgHhgdoPELf1zwUiC6PrxrJaViKaD2tpHk
+IGugw/tBQKvDpQYg7eJyCtCS2bCsvh5FPPCm40Cre2AovidIhjHJ1J9FtlVBJZjG
+JHfF+dgiqKv4mdKyiTaUCiIdJeOvKh1wQTTY3fnyidPiVxL9/Yn/CmNsahrfE8Xe
+a8Le4g6eJk0PeuyhIv698JJFVcV5BVTkQL2YRIgEDrD/HSTm+XygAh+DTQiZrt3S
+i9CBWIU+ysE48soO7sD9iKGcQb3uJC6/l7dIaMW31erxpssXtfWeErtLFXnu7h8J
+SrP5Z5pYcC0ujimNGED1vFlFy5lQOWz3R6gWe44OJeqD3QKO4cthc9yafw/NmtZL
+WU+A7/NO86UK12+IErtDYgAkxZ0RkAb/H8lqWXseL+pnugw2ortLdhJ1PxosKGgq
+aPvfksyNKWKkspJ/9xpAgLoEjcClloExcymOCffpIE71UNhs09WUBIASxe5vIyaU
+61uklltTr2NNds7Sz1P6rwJNqQK2ExTWL3zQkm7xSdfwGBmPbducOjJXiQ1GJs5E
+IR3TJ3Z0fP18YqIMHXxJqt5iEozirtH2Z39xGLidOCNIK/oFiQIAwbRJX6GLDtBE
+QXnhrtzmnU1gzNzpLHpJkNys8v5uNqazlZYeTKCEXyF9xf75XhKpS5yObb5lUznT
+BQQ1SFct8/3JLdgke6lml/PdjL0T1Q98T8mKXAi0BMg0/41lbsuYMqEYpkgFQfYl
+7RsW7w7djVEOKpZOglBWVFUBOHYVyZru4ISzrp5KZxTvtLn8Avqi7gbNV7jZ0XqN
+C7uvJLPB3wyM17KAyW5iNldjXEpkwfle6txMxabmrAJiVBqs8VPagWtz2G5Sfhuc
+N7Om2aewyGHSTP+FVKJo5Zg94Q=3D=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-des-ede3.pem b/unit/cert-client-key-v2=
-des-ede3.pem
new file mode 100644
index 0000000..e94d345
--- /dev/null
+++ b/unit/cert-client-key-v2-des-ede3.pem
@@ -0,0 +1,30 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDgQIVG6rLrQ+fVgCAggA
+MBQGCCqGSIb3DQMHBAizDQ76m4Q4ZQSCBMh50R/dRYR4agewBCpNNVYIHV/wotfZ
+PhhwcJQFZMmp50rCI9rh13w8TSr+KDreXTY+XzvqFS7fbB0JV3QWlv2wvqkAFXoJ
+CYlE40WXg5Qd2H849IyLEil8J5mvoZohDZYNk82zi+PSvkvxJ8d1RJIiHHhmReeC
+0+rDHd9C+Xr2MVBOMA+gimx/P3qtS4jI0qjmzyUiorHa9lvY5qzxbMibi4mEAjBy
+VWviWHszpCwKVapODFlG2r5R2wvmhp4GUGSigi7KtL7hijEbsh4CW2RqYLR733Nx
+WdsyIc4sD3908ttfQSmsSt6vchAMkelwFizGSEFLMsCne3MGjVsLpVitg6nswl6N
+pvngZu0zaggWFVPRIt+vIimeHrujzoiUuzDizjOVzCiyRkrFuJEMwN3l/AaSxUiG
+lOWga1Eb+McH3oJNU1WtrL7gDwfmKFc26D7xNMnGLcdYxfM1F98XfM3FVswaHdC7
+0uTmEmMdhpoNw4CWai37NpigW01cDnxMMpFuX0yTU8GUU/JkBgZ4NHE1sTZrFiOf
+mMr83waumMGwwChhZAd1qDRB35c1HLvVqBt3HkdcyCZP1JBxG4QLrw7IVzG+knlj
+QdrBC/lDNA15wG27v5hRUVEoeFRJkOllUlSqfh0PmJw2t32BP8dS6EsM8eTpnQ7R
+ysqO5CVZ3WTNFwIZ7wD8zmaBOamkZ1OzOluYFL5sBHGRM05pSEsYOivsi7tlp5Gj
+ZQjR+qSKLT34R4QxWhziWgNC/ynjVuWNWX67p1T/ngsM9kGa6cm84XbHQL7CqUyX
+H7vOWtWHGCclS1Ori5vjFP8/qdOVGMpiKnX8HvoBv6zxJvfMYNAz39MMewlfHdCa
+vEvBVwxLYRxbaL1IGNUebXVyn7JNRhuDm1SDNU1ADj8GW4AL5+22D9xArz8Lnkrj
++lvHm1NMIckciFYHraKmIPeJLiLIxDJ1SX+WgJGLo+P0W2TJLHAnQl5a1KzJOsIq
+/y35Q4mFLX0JE4mzAj2S1bsVate4FZpnKqVT0mfN5/UPSnQOpJKRSTYV9QJm1mGb
+gtdvwSvSniyjSSP/MAB+M7C0N4syC4N4sXYXJTKcM3CN/tN4ASycpkWRvXXLWRsj
+BuQq9z50ojdnx+twu2eG3eYRAGjEW7yOD3GHPQOtCx3IQDptmzYf2v4rk9x+IFfT
+L0ZfmyVevXgm9zjHI9s64Ok1g/6SL8lO+wszfjDs1zEgrMRfoVoKOBrWN7fYKiKi
+GBUeaZ9HgcM1ha/a63N1LPK9OPR2w4qh+DpCLpfvhzZN6IRv1oFddws8jwye1pJb
+1Po33NxHUfsOTX+lpc61NOEua7s3/Wu5gm0jBrX5c/aKCfXMsJHzW+0wl4SAXDog
+3Cl29/NAMSQDpQP9A91QSwHYkyzk4rBLcrbx6bQfFSHOqdl2dto+UJfiz+5PzD7s
+I7k72LGzrfIOq4brLbrLIGwj/ani/vvSZnXYzx3uUeP9w1EZSgNKC9HLBW7lyav3
+IlY7HAO2GMVlIdzynHPT3wMXtLqf/ykO+tkrEF4LjOu9r+cdhCxHum22vlgZKL7J
+J044ViKBro0CWL1wajpFQOvG/BG4VDJ/dfGee0iBr4R+CIkaUwVTCdRsibyZRM8E
+FL0=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/cert-client-key-v2-des.pem b/unit/cert-client-key-v2-des.=
pem
new file mode 100644
index 0000000..c34d7bd
--- /dev/null
+++ b/unit/cert-client-key-v2-des.pem
@@ -0,0 +1,29 @@
+-----BEGIN ENCRYPTED PRIVATE KEY-----
+MIIFCzA9BgkqhkiG9w0BBQ0wMDAbBgkqhkiG9w0BBQwwDgQIzeF0Vz5uMq4CAggA
+MBEGBSsOAwIHBAiPr9VLgU0FCwSCBMiTCrQBvWrSvy78jVACd6Lc6eQwCdGiDzdK
+767UB+OTpwy7cbSUt94dcy9KVo2zoHfQFt/4U2c8XZWvmg03S2JtB61W0LPEqNTn
+4AWcYl4DZV7lV2YOzEawDsBz8fJDUcb9t00LKXX6mRZlJ8iXPs0HoYLv93sBf/Z1
+oj4M6Idr6ek1IlGwRZ3qJjHUqOPWj1dybY+LqMz5RHy4+BlH7v7f00sVUTJsCMlj
+fIyluMLQuCAi6y4zTQA+CgZt7BJcGWq3pAXD3AW0lSy+v7ODauPLwR3x8V9hwZ+D
+T/3+Eb7F5yy/7B48j4GgojhI1+Uqy4Jh/lAEKImxEiWM9q7cd9r0pf3hAO6eQLry
+S7aVzcEvvLyQLtCOOJX3C6bfIIkHVvn1OHeMV8beG0V+TcbH5LfIAJfffyqDeiSa
+xaPcHHISN9UqDM7PCTCABlzRO/zCJ8TfbroD2FUX5X6ryMfmPpVyTx2wJqb8Hagu
+2/Lt1kdIhMfBtqFFAfyUwOpcJ3bXDvuEV2qwb+e2wuYBdWgijON/9QH/mfq4dnwE
+drC+8Sx2FY2Tabq/UF13aWCiEU4A6bXKQuDZkwSHMQGAh0MMkzt2WDjv+a2k+Iew
+lTFqzmaIS6COWZx8VVaYbxZXqDqOPCD48BzSVp7oU8T/tplcDmwniNqS91zaU3GU
+AUoSaUaB2KjGCLfieKW7XaVbDIJ2zysU6kayfiYnUYUsGbFKDu8SuzT8VHGXA9Zy
+9EEJgabIOqecPmGSQQu3kpb9NF0KxNQC8WhnyGt6WEE9sG36US79tfMzCThBA6S5
+cP2P86NLEEyYlDSQYxmh46TqYiPtdmOZ7RKdAMnX50PRYroMMu91VCmkKlr1Twnj
+jIRzH6I8kRDNdYOcSit4HbIOzGy6unJhfVHhMBH7zIVWF1se8+Ri7M7veeiixbE/
+aWl0qZ1wMIZYKSHwgNl4LZwaxyvLR9n0rPkrJVOEmuKq2vyIjcus41YqKVm6zYWf
+gJSBXSYBEJq11wDCWJGVIi1VGS4PeA4t0u8af0PD9+Nyj2DfaQENaOyKsCAFqfZU
+rjk10dmpuAnEEE+uEqrpHeqaYSPZT08EkaZy9meUgtFeIqTzgXC9oHxTqJpj3+as
+ln7p28gMosEEK3At7kpMyD/gQmCeP+cyK7dFGP46D1qTtlSeWi+ZNa/W/ULvDcQw
+SWmT168M1aA5bHkHfK+xcFo776YGoP6tOaJeT684Tyj/35GTNldYdeQIFykQ5dRV
+TO/zO1WopBNVT+RQnOzJXvsiRJZ7c6Y2S1XyOj9t9LJndDD65leLWqKeepHmKMqD
+h78Kea72+3s+STj7D2pJFSeaPaBc9G0vZhDFqWyga9nHFNcF/k6jj22NDJyfgj1F
+1tEoMNn+Cu1xh1Krl6KHEFlcMm6j9XuU/BhDBMJhO8DfpQye/xNSYq+KFrQ1Emdl
+X/ynmsFsfmVv4P1YSg7/z87ZlBmcJUHePHpM1eiWygW8ujCsOybihAj3OxVpDF9R
+RGlsGvHXkNDVSQG5y/zron8IJjbixdAe1BUdYfI8V6f13fUbJVOg5oeICsEcna3v
+wnNE+gYCF3uEzoBx+N+tRHvJ0t2U9rHGXphefCE50mPCZ0nYps/OPSq0OCeGjgA=3D
+-----END ENCRYPTED PRIVATE KEY-----
diff --git a/unit/test-pem.c b/unit/test-pem.c
index 0a075dd..9090a24 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -87,6 +87,42 @@ static void test_pem(const void *data)
 	l_free(decoded);
 }
 =

+static void test_encrypted_pkey(const void *data)
+{
+	const char *encrypted_pem =3D data;
+	const char *plaintext_pem =3D "unit/cert-client-key-pkcs8.pem";
+	bool encrypted;
+	size_t size1, size2;
+	uint8_t *pkey1, *pkey2;
+
+	encrypted =3D false;
+	assert(!l_pem_load_private_key(encrypted_pem, NULL,
+					&encrypted, &size1));
+	assert(encrypted);
+
+	encrypted =3D false;
+	assert(!l_pem_load_private_key(encrypted_pem, "wrong-passwd",
+					&encrypted, &size1));
+	assert(encrypted);
+
+	encrypted =3D false;
+	pkey1 =3D l_pem_load_private_key(encrypted_pem, "abc",
+					&encrypted, &size1);
+	assert(pkey1);
+	assert(encrypted);
+
+	pkey2 =3D l_pem_load_private_key(plaintext_pem, NULL,
+					&encrypted, &size2);
+	assert(pkey2);
+	assert(!encrypted);
+
+	assert(size1 =3D=3D size2);
+	assert(!memcmp(pkey1, pkey2, size1));
+
+	l_free(pkey1);
+	l_free(pkey2);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -98,5 +134,17 @@ int main(int argc, char *argv[])
 =

 	l_test_add("pem/empty label", test_pem, &empty_label);
 =

+	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
+			test_encrypted_pkey,
+			"unit/cert-client-key-md5-des.pem");
+	l_test_add("pem/v2 DES encrypted Private Key", test_encrypted_pkey,
+			"unit/cert-client-key-v2-des.pem");
+	l_test_add("pem/v2 DES EDE3 encrypted Private Key", test_encrypted_pkey,
+			"unit/cert-client-key-v2-des-ede3.pem");
+	l_test_add("pem/v2 AES128 encrypted Private Key", test_encrypted_pkey,
+			"unit/cert-client-key-v2-aes128.pem");
+	l_test_add("pem/v2 AES256 encrypted Private Key", test_encrypted_pkey,
+			"unit/cert-client-key-v2-aes256.pem");
+
 	return l_test_run();
 }
-- =

2.11.0


--===============4137665560162417927==--

