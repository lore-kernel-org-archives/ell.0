Content-Type: multipart/mixed; boundary="===============3928956921850438124=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] main: Add handler for SIGSEGV signal
Date: Tue, 26 Jan 2021 10:02:03 +0100
Message-ID: <B16AD30C-C72C-4E20-A1D5-9BDC126598E1@holtmann.org>
In-Reply-To: <20210125223155.10508-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3928956921850438124==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

> When an ell main loop based process is spun off as a child
> and the parent process dies due to a segfault, the child process
> is still left running and needs to detect the segfault condition.
> To address this need, add watch and signal handler for SIGSEGV.
> ---
> ell/main.c | 11 +++++++++++
> 1 file changed, 11 insertions(+)
> =

> diff --git a/ell/main.c b/ell/main.c
> index a479b74..712cfb7 100644
> --- a/ell/main.c
> +++ b/ell/main.c
> @@ -619,6 +619,14 @@ static void sigterm_handler(void *user_data)
> 		data->callback(SIGTERM, data->user_data);
> }
> =

> +static void sigsegv_handler(void *user_data)
> +{
> +	struct signal_data *data =3D user_data;
> +
> +	if (data->callback)
> +		data->callback(SIGSEGV, data->user_data);
> +}
> +

actually this is not enough. I never included SIGSEGV here for the simple r=
eason since you have to do a lot of work when that signal happens.

What we need to do is to add proper child spawning handling that does all t=
he nasty signal handling for you. Otherwise you are just about to create zo=
mbies. For now if you need child handling, then add your own signal handler=
 instead trying to overload l_main_run_with_signal with it.

Regards

Marcel

--===============3928956921850438124==--

