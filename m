Content-Type: multipart/mixed; boundary="===============9162538319765640426=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key
 for TLS tests
Date: Mon, 08 Aug 2016 12:42:45 -0500
Message-ID: <57A8C495.7030204@gmail.com>
In-Reply-To: <20160808172545.6648-4-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9162538319765640426==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 08/08/2016 12:25 PM, Mat Martineau wrote:
> ---
>   unit/cert-server-key-pkcs8.pem | 28 ++++++++++++++++++++++++++++
>   unit/gencerts.sh               |  1 +
>   unit/test-tls.c                | 16 ++++++++--------
>   3 files changed, 37 insertions(+), 8 deletions(-)
>   create mode 100644 unit/cert-server-key-pkcs8.pem
>

I wonder, what's the reasoning behind this change?

Regards,
-Denis


--===============9162538319765640426==--

