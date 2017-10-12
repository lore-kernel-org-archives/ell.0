Content-Type: multipart/mixed; boundary="===============2327883205697028423=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] genl: Make iovec parameter const
Date: Thu, 12 Oct 2017 09:08:53 -0500
Message-ID: <e62951bc-1b44-b046-2c76-b0e368ef356f@gmail.com>
In-Reply-To: <20171011221239.8656-2-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2327883205697028423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/11/2017 05:12 PM, Ossama Othman wrote:
> Make the iovec parameter of l_genl_msg_append_attrv() const since it
> isn't modified by the function.  This allows a pointer to a const
> struct iovec to be passed as an argument without casting away the
> const.
> ---
>   ell/genl.c | 3 ++-
>   ell/genl.h | 2 +-
>   2 files changed, 3 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============2327883205697028423==--

