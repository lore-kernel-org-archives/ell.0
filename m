Content-Type: multipart/mixed; boundary="===============7462081414153974191=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] util: Remove semicolons in single-statement macros
Date: Mon, 24 Oct 2016 14:06:05 -0500
Message-ID: <580E5B9D.3090904@gmail.com>
In-Reply-To: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7462081414153974191==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/24/2016 01:44 PM, Mat Martineau wrote:
> Including semicolons in L_AUTO_CLEANUP_VAR and L_AUTO_FREE_VAR caused
> gcc to emit errors related to mixed declarations and code when there
> were multiple L_AUTO_* lines or declarations following an L_AUTO_ macro.
> ---
>   ell/util.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============7462081414153974191==--

