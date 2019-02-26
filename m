Content-Type: multipart/mixed; boundary="===============5010475301390442072=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Remove loop initial declaration.
Date: Tue, 26 Feb 2019 12:32:41 -0600
Message-ID: <f1c871bd-9a49-9517-28ce-2ef05ec4b395@gmail.com>
In-Reply-To: <20190226180931.32239-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5010475301390442072==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 02/26/2019 12:09 PM, Ossama Othman wrote:
> Move the variable declaration in test_string.c:test_strv_append() out
> of the for-loop initial declaration to support older C standards, as
> well as to conform to the ELL coding style.
> ---
>   unit/test-string.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============5010475301390442072==--

