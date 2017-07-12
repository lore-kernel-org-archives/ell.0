Content-Type: multipart/mixed; boundary="===============0842241428957579572=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] dbus: Fix use-after-free in property changed signals
Date: Wed, 12 Jul 2017 15:40:43 -0700
Message-ID: <alpine.OSX.2.21.1707121538520.31204@mjmartin-mac01.sea.intel.com>
In-Reply-To: <20170712202302.6373-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0842241428957579572==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 12 Jul 2017, Mat Martineau wrote:

> Configuring with --enable-asan and running test-dbus-properties revealed
> that properties_set_complete() was accessing a reply message after it
> was sent, but l_dbus_send() had already unref'd and freed the message.
>
> Grabbing a reference to the reply before sending fixes the problem.
> ---
> ell/dbus-service.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)

Ok, this is the last patch for now. Everything runs cleanly with =

asan/lsan/ubsan or valgrind now, including test-tls and test-key with an =

appropriate kernel.

--
Mat Martineau
Intel OTC

--===============0842241428957579572==--

