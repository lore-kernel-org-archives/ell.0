Content-Type: multipart/mixed; boundary="===============8157811724358441309=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 10/10] unit: Test loading encrypted private key PEM files
Date: Fri, 11 Aug 2017 15:26:22 -0500
Message-ID: <064ff25a-e923-d25b-6cdc-e648dd630872@gmail.com>
In-Reply-To: <20170810231016.29445-10-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8157811724358441309==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
> ---
>   unit/cert-client-key-md5-des.pem     | 29 ++++++++++++++++++++++
>   unit/cert-client-key-v2-aes128.pem   | 30 ++++++++++++++++++++++
>   unit/cert-client-key-v2-aes256.pem   | 30 ++++++++++++++++++++++
>   unit/cert-client-key-v2-des-ede3.pem | 30 ++++++++++++++++++++++
>   unit/cert-client-key-v2-des.pem      | 29 ++++++++++++++++++++++
>   unit/test-pem.c                      | 48 +++++++++++++++++++++++++++++=
+++++++
>   6 files changed, 196 insertions(+)
>   create mode 100644 unit/cert-client-key-md5-des.pem
>   create mode 100644 unit/cert-client-key-v2-aes128.pem
>   create mode 100644 unit/cert-client-key-v2-aes256.pem
>   create mode 100644 unit/cert-client-key-v2-des-ede3.pem
>   create mode 100644 unit/cert-client-key-v2-des.pem
> =


Makefile.am changes seem to be missing.  e.g. adding the new pem files =

to unit_test_data_files.

Regards,
-Denis


--===============8157811724358441309==--

