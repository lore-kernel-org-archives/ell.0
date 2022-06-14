Received: from mail-0201.mail-europe.com (mail-0201.mail-europe.com [51.77.79.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7508184A
	for <ell@lists.linux.dev>; Tue, 14 Jun 2022 08:32:41 +0000 (UTC)
Date: Tue, 14 Jun 2022 08:32:15 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=protonmail3; t=1655195545; x=1655454745;
	bh=dX6QZV+ayer35QYSu0HC3ng04uTVm1KW9UW+mo1A4Kw=;
	h=Date:To:From:Cc:Reply-To:Subject:Message-ID:In-Reply-To:
	 References:Feedback-ID:From:To:Cc:Date:Subject:Reply-To:
	 Feedback-ID:Message-ID;
	b=xGemw8QAz/TNLyCfYcyjKHaawzew2D0BpYCsVju9VS5Vs0sXUG93J/zTFXeYc732H
	 ORMi+js4PSAh7hlAz3IRd2+mn8iFaCbZ0Tn3sm4dU3lnj4laPdJcA8mdLRKhDil9BD
	 y20kM/arFTbZulQd+yTXRyFqzgwPrAcKJyOOi72FYXfg8L7CPwFIt+b481T4E/BP8L
	 0j84Z0LSEO3LvH7Fk1l6a4SktZ1RgXGJviyHaRWb7THCLqbjupDZuStYq1Iv2ogAIM
	 U0i4uEMiGwFTNDrVmZK1bGOal1yQG2p89o7nTaMP61+Ug4ExJ/7j7ggTUHlFgItoWX
	 mO52oUmPy9rXw==
To: Denis Kenzior <denkenz@gmail.com>
From: Ryan McClue <re.mcclue@protonmail.com>
Cc: "ell@lists.linux.dev" <ell@lists.linux.dev>
Reply-To: Ryan McClue <re.mcclue@protonmail.com>
Subject: Re: Sending and Receiving DBUS Message
Message-ID: <PyTvMi1te-mCaRAe18nuXlJoIfYvu3xK9CP4XDweGT28egcFExPPkellIjOWwQXzxEbT3qH-KPmokmIcTaAq7UL4FIDs5jWEgA8yW676FTo=@protonmail.com>
In-Reply-To: <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com>
References: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com> <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com>
Feedback-ID: 25557543:user:proton
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Thank you Denis. That was very helpful.
However, in regards to running the main loop, I seem to have encountered an=
 issue. It seems the main loop only iterates 10 times and then stalls. Cons=
ider this code:

static void start_discovery_callback(struct l_dbus_message *msg, void *user=
_data) {
  printf("start discovery\n");
}

int main(int argc, char *argv[]) {
  l_main_init();

  struct l_dbus *conn =3D l_dbus_new_default(L_DBUS_SYSTEM_BUS);

  struct l_dbus_message *msg =3D l_dbus_message_new_method_call(conn, "org.=
bluez", "/org/bluez/hci0",
                                                              "org.bluez.Ad=
apter1", "StartDiscovery");

  l_dbus_send_with_reply(conn, msg, start_discovery_callback, NULL, NULL);

  l_dbus_message_unref(msg);

  int counter =3D 0;
  int ell_main_loop_timeout =3D l_main_prepare();
  while (true) {
    printf("counter: %d\n", counter++);

    l_main_iterate(ell_main_loop_timeout);
  }

  l_dbus_destroy(conn);

  l_main_exit();
}


'counter' is only printed from 0 to 9. Also, the message "start discovery" =
is never printed. What is going on here?

--
Ryan McClue, Sydney

Sent with Proton Mail secure email.
------- Original Message -------
On Wednesday, June 8th, 2022 at 1:07 AM, Denis Kenzior <denkenz@gmail.com> =
wrote:


> Hi Ryan,
>
> On 6/7/22 06:05, Ryan McClue wrote:
>
> > Upon examining 'examples/dbus-client.c', it does not seem to contain DB=
US message sending and receiving/parsing.
>
>
> Hmm.. this particular example exercises the l_dbus_client/l_dbus_proxy AP=
I .
> These take care of parsing DBus.Properties messages for you. It should be=
 very
> easily adapted to what you need.
>
> You can also take a peek at the dbus unit tests in unit/ which exercise t=
he dbus
> API in various ways, including message parsing. 'unit/test-dbus-message.c=
' might
> have what you want.
>
> > As a simple example, I want to call the "Get()" method with arguments "=
org.freedesktop.hostname1" and "Hostname". This method is of the interface =
"org.freedesktop.DBus.Properties". I want to parse the return of this metho=
d call to get the hostname of my machine.
>
>
> If the interface implements DBus.Properties properly, then you really do =
not
> need to invoke the .Get() method directly. l_dbus_proxy_get_property() sh=
ould
> be all you need.
>
> But if you still want to:
>
> > Take my example code (with error handling omitted):
> >
> > l_main_init();
> >
> > struct l_dbus *conn =3D l_dbus_new_default(L_DBUS_SYSTEM_BUS);
> > const char *service =3D "org.freedesktop.hostname1";
> > const char *object =3D "/org/freedesktop/hostname1";
> > const char *interface =3D "org.freedesktop.DBus.Properties";
> > const char *method =3D "Get";
> >
> > struct l_dbus_message *msg =3D l_dbus_message_new_method_call(conn, ser=
vice, object, interface, method);
> > const char *get_interface =3D "org.freedesktop.hostname1";
> > const char *get_property =3D "Hostname";
> > l_dbus_message_set_arguments(msg, "ss", get_interface, get_property);
>
>
>
> So far this looks fine. You need to invoke l_dbus_send_with_reply() to se=
nd the
> message and register a callback for the reply.
>
> > ///////////////////////////////////
> > // How to send and parse output????
> > ///////////////////////////////////
>
>
> Something like:
>
> l_dbus_send_with_reply(dbus_conn, msg, get_hostname_cb, NULL, NULL);
>
> > l_dbus_destroy(dbus_conn);
> > l_main_exit();
>
>
> Note that the main event loop must be running until you receive the reply=
, so
> you need l_main_run...() somewhere and only perform these two steps after=
 the
> main loop has exited.
>
> ell is a purely event-loop driven API, so we have no blocking version of
> l_dbus_send() unlike other D-Bus binding libraries.
>
>
> static void get_hostname_cb(struct l_dbus_message *reply, void *user_data=
)
> {
> struct l_dbus_message_iter iter;
> const char *hostname;
>
> l_dbus_message_get_arguments(reply, "v", &iter);
>
> l_dbus_message_iter_get_variant(&iter, "s", &hostname);
> }
>
> > Could someone please fill in the blanks for me?
> > Thanks
> >
> > --
> > Ryan McClue, Sydney
>
>
> Hope this helps.
>
> Regards,
> -Denis
