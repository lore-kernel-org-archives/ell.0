Content-Type: multipart/mixed; boundary="===============0286219915163373525=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] unit: Clean up leaks in test-dbus-watch
Date: Wed, 12 Jul 2017 21:53:38 +0200
Message-ID: <B7377DA6-0301-46C3-855B-4D8F719F9195@holtmann.org>
In-Reply-To: <20170712194934.23933-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0286219915163373525==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> Use of the internal _dbus_message_set_sender() function in
> test-dbus-watch resulted in message structures that were not completely
> freed, which caused error reports when ELL was configured with
> --enable-asan. Manually clearing the message sender resolves the
> problem.
> ---
> unit/test-dbus-watch.c | 4 ++++
> 1 file changed, 4 insertions(+)

patch has been applied.

Regards

Marcel


--===============0286219915163373525==--

