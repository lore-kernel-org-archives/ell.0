Content-Type: multipart/mixed; boundary="===============6576003199448422594=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] unit: Move tls_cert_load_file to relevant unit tests
Date: Fri, 14 Dec 2018 10:01:22 -0600
Message-ID: <84e2a0b9-5c3f-2df2-e2ff-d8891f0743e3@gmail.com>
In-Reply-To: <20181213195746.32144-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6576003199448422594==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> tls_cert_load_file and l_pem_load_certificate have no users other than
> the two unit tests and have little to do with TLS.
> ---
>   unit/test-key.c | 26 ++++++++++++++++++++------
>   unit/test-tls.c | 28 +++++++++++++++++++++-------
>   2 files changed, 41 insertions(+), 13 deletions(-)
> =


Patch 6 & 7 applied, thanks.

Regards,
-Denis


--===============6576003199448422594==--

