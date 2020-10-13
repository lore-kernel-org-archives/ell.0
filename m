Content-Type: multipart/mixed; boundary="===============6404571857213029982=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] io: Do not call disconnect handler in destroyer
Date: Tue, 13 Oct 2020 13:34:38 -0500
Message-ID: <caa00362-d4d1-5cb2-70a5-4d2d6d533c06@gmail.com>
In-Reply-To: <20201012221354.242562-2-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6404571857213029982==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 10/12/20 5:13 PM, Inga Stotland wrote:
> When a client is calling l_io_destroy() there is no need to inform
> that same client that io has been disconnected.

Hmm... the client invoking l_io_destroy might be different from the one tha=
t set =

the disconnect handler?  Also, I think this might break some clients. =

ofono.git/plugins/mbim.c for example seems like it is affected due to how =

mbim_device is implemented...

> =

> Removing the disconnect callback from l_io_destroy() eliminates the
> need to zero out and preserve disconnect handler data when invoking
> disconnect handler in io_closed().
> =

> Also, rename static function io_closed() to io_disconnected() to
> reflect the actual functionality.

Is anything really broken due to the current behavior?

> ---
>   ell/io.c | 32 +++++++++-----------------------
>   1 file changed, 9 insertions(+), 23 deletions(-)
> =


Regards,
-Denis
--===============6404571857213029982==--

