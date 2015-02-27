Content-Type: multipart/mixed; boundary="===============6442546053202391704=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH_v2] genl: Introduce new api
Date: Fri, 27 Feb 2015 11:03:20 -0600
Message-ID: <54F0A358.60106@gmail.com>
In-Reply-To: <1425028425-9441-1-git-send-email-ravikumar.veeramally@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6442546053202391704==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ravi,

On 02/27/2015 03:13 AM, Ravi kumar Veeramally wrote:
> Introducing l_genl_family_send_and_unref, l_genl_family_dump_and_unref
> wrapper functions for l_genl_family_send and l_genl_family_dump
> but it unref the message no matter of what the result is.
> ---
>   ell/genl.c | 28 ++++++++++++++++++++++++++++
>   ell/genl.h | 10 ++++++++++
>   2 files changed, 38 insertions(+)
>

I decided to fix this differently.  The fix was to have =

l_genl_family_send and l_genl_family_dump not take a ref, since we never =

actually kept the message after sending it.

This also makes it consistent with the ell dbus message API.

Regards,
-Denis


--===============6442546053202391704==--

