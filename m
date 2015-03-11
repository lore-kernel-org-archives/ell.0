Content-Type: multipart/mixed; boundary="===============1071356863567076700=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] genl: Normilize functions exports and parameters
 check as it should
Date: Wed, 11 Mar 2015 00:03:19 -0500
Message-ID: <54FFCC97.402@gmail.com>
In-Reply-To: <1425986070-8808-2-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1071356863567076700==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 03/10/2015 06:14 AM, Tomasz Bursztyka wrote:
> Ell follows a certain way of exporting library functions and checking
> parameter's validity, so let's apply these rules to genl.c
> ---
>   ell/genl.c | 152 ++++++++++++++++++++++++++++++++++--------------------=
-------
>   1 file changed, 85 insertions(+), 67 deletions(-)
>

Applied after fixing up the commit header.

Regards,
-Denis


--===============1071356863567076700==--

