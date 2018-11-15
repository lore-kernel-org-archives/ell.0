Content-Type: multipart/mixed; boundary="===============4586581678013279219=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] signal: Restrict signal_mask to file scope
Date: Thu, 15 Nov 2018 10:46:30 +0100
Message-ID: <849A00FD-00C1-41BA-8B22-CD1E977C92E0@holtmann.org>
In-Reply-To: <77061a03-2827-7bfd-c556-2e085efd9992@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4586581678013279219==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

>> ---
>>  ell/signal.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> =

> Whoops.  Thanks for cleaning up after me.
> =

> Applied.

you might have forgotten to push your tree. So I picked up Mat=E2=80=99s pa=
tch and fixed the signal mask restore in case of signalfd failure.

Regards

Marcel


--===============4586581678013279219==--

