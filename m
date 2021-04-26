Content-Type: multipart/mixed; boundary="===============0969139167590217231=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] tester: Remove timeout if pre-setup failed
Date: Mon, 26 Apr 2021 10:34:24 -0500
Message-ID: <711982f6-e790-22b7-9cbd-a890c23b6340@gmail.com>
In-Reply-To: <20210423182656.97424-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0969139167590217231==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 4/23/21 1:26 PM, Inga Stotland wrote:
> If test pre setup stage fails, remove test run timeout.
> Also, fix a stray call to free(): should be l_free().
> ---
>   ell/tester.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============0969139167590217231==--

