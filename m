Content-Type: multipart/mixed; boundary="===============8612008344807497049=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Add l_genl_msg_append_attrv
Date: Mon, 10 Oct 2016 10:04:23 -0500
Message-ID: <57FBADF7.4020602@gmail.com>
In-Reply-To: <1475745502-4866-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8612008344807497049==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/06/2016 04:18 AM, Andrew Zaborowski wrote:
> Try to minimise the amount of buffers allocated and copied by clients
> when building a message attribute that is a concatenation of other
> buffers, such as an IE sequence.
> ---
>   ell/genl.c | 32 ++++++++++++++++++++++++++++++++
>   ell/genl.h |  2 ++
>   2 files changed, 34 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============8612008344807497049==--

