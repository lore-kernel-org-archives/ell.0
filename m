Content-Type: multipart/mixed; boundary="===============4606192308733970042=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: ELL building broken for 32bit systems
Date: Fri, 31 May 2019 17:41:12 +0000
Message-ID: <db86584906ab410ff151ebd77266ab3d4eea3ff3.camel@intel.com>
In-Reply-To: <cb7cb78f01fb933780c895ef93e065f7266d2f93.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4606192308733970042==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 2019-05-31 at 17:28 +0000, Gix, Brian wrote:
> As part of my Bluetooth Mesh change-over from user-space crypto to
> ELL
> provided cipher and checksum routines,  I have been building on all
> the
> platforms I have available to me, including Fedora-30 running on
> 32bit
> i686 architecture.
> =

> Here are the issues I encountered:
> =

> There is an unchecked build dependancy on "xxd", which appears to be
> provided by the vim-common package.  This probably affects all
> platforms, but my 32-bit F30 installation is deliberately kept
> "minimal", so that is where it showed up.


Actually for this one, xxd is checked for, but it doesn't cause a
failure of ./bootstrap-configure, even though it correctly determines
that xxd is missing.

> =

> =

> After installing vim-common, there is a build error that is unique to
> the 32bit F30 (it works fine on 64 bit systems).  When doing a full
> build (and when doing a build of *only* unit/test-cipher) I get the
> following error when building ell/genl.c:
> =

> [ell]$ make -k unit/test-cipher
>   CC       ell/genl.lo
> In file included from /usr/include/string.h:494,
>                  from ell/util.h:26,
>                  from ell/genl.c:32:
> In function =E2=80=98strncpy=E2=80=99,
>     inlined from =E2=80=98family_add_mcast=E2=80=99 at ell/genl.c:240:2,
>     inlined from =E2=80=98family_add_mcast.isra.0=E2=80=99 at ell/genl.c:=
224:13:
> /usr/include/bits/string_fortified.h:106:10: error:
> =E2=80=98__builtin_strncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>   106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>       |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~
> ~~~~~~~~
> In function =E2=80=98strncpy=E2=80=99,
>     inlined from =E2=80=98get_family_callback=E2=80=99 at ell/genl.c:1049=
:4:
> /usr/include/bits/string_fortified.h:106:10: error:
> =E2=80=98__builtin_strncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>   106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>       |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~
> ~~~~~~~~
> In function =E2=80=98strncpy=E2=80=99,
>     inlined from =E2=80=98family_alloc=E2=80=99 at ell/genl.c:164:2:
> /usr/include/bits/string_fortified.h:106:10: error:
> =E2=80=98__builtin_strncpy=E2=80=99
> specified bound 16 equals destination size [-Werror=3Dstringop-
> truncation]
>   106 |   return __builtin___strncpy_chk (__dest, __src, __len, __bos
> (__dest));
>       |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> ~~
> ~~~~~~~~
> cc1: all warnings being treated as errors
> make: *** [Makefile:1780: ell/genl.lo] Error 1
> make: Target 'unit/test-cipher' not remade because of errors.
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell

--===============4606192308733970042==
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
hkiG9w0BCQUxDxcNMTkwNTMxMTc0MTExWjAjBgkqhkiG9w0BCQQxFgQUVGSeG2R4dEULKebfhyr0
Rzc3AXkwDQYJKoZIhvcNAQEBBQAEggEAVqMCvIQLdRh8jc78KWRSHMKgtRGvB0s/IWA281MgD1rZ
FTmdBJU/KjeAQ9b/d9mk6dN9N65G9DLm/iO0jRehx57iHZsXnBpRVqv9KS6ktMZtnQMMKi89pMbg
hW23MEvnWy9Up8e2ByVW00zlkShAq4syDFUWhhagRi2wg3dopeDNnV5eTarKL+CakpifPrhuAIUd
WouE4QbjbsMJuzht3/Z/V77y61xv/f7rjQmgnFoU2rSbcB8gh8xKf4M12rzmmwiHDUweC37ioxzC
TpR0cO6qhWCwZkHh9u+/8uBl4LN2GoDy/2LxxHbK44AC624Hg7sDVqmASQoa060/wZs2rAAAAAAA
AA==
--===============4606192308733970042==--

