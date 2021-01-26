Content-Type: multipart/mixed; boundary="===============1060194439945282423=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] main: Add handler for SIGSEGV signal
Date: Mon, 25 Jan 2021 18:35:19 -0600
Message-ID: <af3f83eb-d377-1b90-7cb5-d0027a5e436c@gmail.com>
In-Reply-To: <20210125223155.10508-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1060194439945282423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 1/25/21 4:31 PM, Inga Stotland wrote:
> When an ell main loop based process is spun off as a child
> and the parent process dies due to a segfault, the child process
> is still left running and needs to detect the segfault condition.
> To address this need, add watch and signal handler for SIGSEGV.
> ---
>   ell/main.c | 11 +++++++++++
>   1 file changed, 11 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============1060194439945282423==--

