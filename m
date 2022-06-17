Received: from mail-41103.protonmail.ch (mail-41103.protonmail.ch [185.70.41.103])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92DC37F
	for <ell@lists.linux.dev>; Fri, 17 Jun 2022 05:06:01 +0000 (UTC)
Date: Fri, 17 Jun 2022 04:57:38 +0000
Authentication-Results: mail-41103.protonmail.ch;
	dkim=pass (2048-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="ufDt12Z6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=protonmail3; t=1655441866; x=1655701066;
	bh=Q77Ne2JM1C0L2Ls6KONYHwUfKh4jFpfEGPH2fBZ4mLs=;
	h=Date:To:From:Cc:Reply-To:Subject:Message-ID:In-Reply-To:
	 References:Feedback-ID:From:To:Cc:Date:Subject:Reply-To:
	 Feedback-ID:Message-ID;
	b=ufDt12Z6RBvHXNu3NW/pnyj/EXqp70l02TDkRJ48APn8rRaKXQaSkOPonmsVKBmg5
	 9/OTeqfegtTIi8wRY97JnqkXNOn3eC7/KQOJM9yQeABSkLIZJ/4HP0dexuGem0Zdro
	 XeK+ckLEKWYsE8RE6bxOULcsbkpM+Rq36qMVdCHaXkwqz4JtF2GfKL5qdUyWSLr6/P
	 bCtvDQOUMT7ncqc2KsfmZWZVN9uhKC59bakvBazHNif0U0oq68DZtk4tAxsdgObI1G
	 2ao9/DhaxhLb63DzNaL07uqR9B88Aa49wmyqk6YzB1CEuO1afSAuLnp6dzler1PENo
	 6C4roxJyxV5Mw==
To: Denis Kenzior <denkenz@gmail.com>
From: Ryan McClue <re.mcclue@protonmail.com>
Cc: "ell@lists.linux.dev" <ell@lists.linux.dev>
Reply-To: Ryan McClue <re.mcclue@protonmail.com>
Subject: Re: Sending and Receiving DBUS Message
Message-ID: <Yf3F4N4nJ3gEDc_40X7xmoTA9QM3f5flX4S9k6KlO76jGIQUGy1P5T_H8zg42WfbhZwOVIt-P0I3Lu6JKed1n2rGEUsRD5cangC4ADneh40=@protonmail.com>
In-Reply-To: <603b4d33-aa7b-1974-f41b-d9930d5f0eba@gmail.com>
References: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com> <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com> <PyTvMi1te-mCaRAe18nuXlJoIfYvu3xK9CP4XDweGT28egcFExPPkellIjOWwQXzxEbT3qH-KPmokmIcTaAq7UL4FIDs5jWEgA8yW676FTo=@protonmail.com> <b448db72-549e-f748-3851-9d297b7ea05d@gmail.com> <wk-twE8P7fmAykCAdLvcaPGWWzSscceUiLEpbWSuUV1-uQWzsrMcDyNszaOKEMiPRWLhATf11gMgyp9VUcGXPVkkFFzeTOnLhSN9CX9G1x8=@protonmail.com> <603b4d33-aa7b-1974-f41b-d9930d5f0eba@gmail.com>
Feedback-ID: 25557543:user:proton
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Thank you again. Yes, I just blindly assumed that no arguments required no =
setup.

My issue now is parsing "oa{sa{sv}}" as matched by the Bluez InterfacesAdde=
d signal.
I believe this extends to parsing any nested dictionary.
I tried looking in 'unit/*' for examples, however they only parse string ke=
ys, not the actual nested dictionary.

Consider my example code:

static void cb(struct l_dbus_message *msg, void *user_data) {
  struct l_dbus_message_iter root_keys_iter, device_keys_iter =3D {0};
  struct l_dbus_message_iter root_values_iter, device_values_iter =3D {0};
  bool argument_received =3D false;

  const char *object =3D NULL;
  bool have_msg =3D l_dbus_message_get_arguments(msg, "oa{sa{sv}}", &object=
, &root_keys_iter);
  if (have_msg) {
    while (true) {
      const char *root_key =3D NULL;
      argument_received =3D l_dbus_message_iter_next_entry(&root_keys_iter,=
 &root_key, &root_values_iter);
      if (!argument_received) break;

      if (strcmp(root_key, "org.bluez.Device1") =3D=3D 0) {
        argument_received =3D l_dbus_message_iter_get_variant(&root_values_=
iter, "a{sv}", &device_keys_iter);
        if (argument_received) {
          break;
        } else {
          printf("org.bluez.Device1 dict expected but not received\n");
          exit(1);
        }
      }
    }
  } else {
    printf("InterfacesAdded dict expected but not received\n");
    exit(1);
  }
}

The message "org.bluez.Device1 dict expected but not received" was printed.=
 Why?

--
Ryan McClue, Sydney

Sent with Proton Mail secure email.
------- Original Message -------
On Wednesday, June 15th, 2022 at 1:53 PM, Denis Kenzior <denkenz@gmail.com>=
 wrote:


> Hi Ryan,
>
> > > > struct l_dbus_message *msg =3D l_dbus_message_new_method_call(conn,=
 "org.bluez", "/org/bluez/hci0",
> > > > "org.bluez.Adapter1", "StartDiscovery");
>
>
> You also need to make sure to set the arguments on the message. In your c=
ase:
>
> l_dbus_message_set_arguments(msg, "");
>
> We probably should have l_dbus_send* reject messages which have not been =
setup
> properly. But since you're not checking the error, it wouldn't really hel=
p :)
>
> > > > l_dbus_send_with_reply(conn, msg, start_discovery_callback, NULL, N=
ULL);
> > > >
> > > > l_dbus_message_unref(msg);
>
>
> Here's a functional example based on your code.
>
> http://dpaste.com/8GVMYE3DY
>
> Regards,
> -Denis
