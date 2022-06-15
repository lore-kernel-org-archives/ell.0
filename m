Received: from mail-0201.mail-europe.com (mail-0201.mail-europe.com [51.77.79.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 243CF46A4
	for <ell@lists.linux.dev>; Wed, 15 Jun 2022 00:41:22 +0000 (UTC)
Date: Wed, 15 Jun 2022 00:41:08 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=protonmail3; t=1655253672; x=1655512872;
	bh=p97pnNfTexaxdxwBcl4ei+pFuO9pdbsn2aO6vc6wk7Q=;
	h=Date:To:From:Cc:Reply-To:Subject:Message-ID:In-Reply-To:
	 References:Feedback-ID:From:To:Cc:Date:Subject:Reply-To:
	 Feedback-ID:Message-ID;
	b=HtObegajTnh82ue2JV1wGBHWvLFK45NWPfidYV3P2miHJxRDDrQmy9dwWngr2f/N3
	 c9FaFdORjHGAIztu3pnFeRSXIOLPnsMAE/2UEbGuV4JupkweTX4mfxyrUjZe1bCzFJ
	 aoB6UXc8c8E8q7z/PCaPmZSTPQVbMl2T3KFHjzJzGZAAFhSXI0zD7QXzhlicdrPwUl
	 Rtdigqf9Z+GUkRbgTG6O3rbdi49DWvWZGMQLBIrhR53ry7Ow9lsHfORjWXeq8KnwMa
	 nmjuAXq5c4BWSvt0I9K183QazPatLhvvSw3XnI6YvH5CDWa90MYigRnuH5eL0690sj
	 e82vnoB7mgo8w==
To: Denis Kenzior <denkenz@gmail.com>
From: Ryan McClue <re.mcclue@protonmail.com>
Cc: "ell@lists.linux.dev" <ell@lists.linux.dev>
Reply-To: Ryan McClue <re.mcclue@protonmail.com>
Subject: Re: Sending and Receiving DBUS Message
Message-ID: <wk-twE8P7fmAykCAdLvcaPGWWzSscceUiLEpbWSuUV1-uQWzsrMcDyNszaOKEMiPRWLhATf11gMgyp9VUcGXPVkkFFzeTOnLhSN9CX9G1x8=@protonmail.com>
In-Reply-To: <b448db72-549e-f748-3851-9d297b7ea05d@gmail.com>
References: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com> <f6c025d3-a2e8-9f53-8b5b-71703be4c2f6@gmail.com> <PyTvMi1te-mCaRAe18nuXlJoIfYvu3xK9CP4XDweGT28egcFExPPkellIjOWwQXzxEbT3qH-KPmokmIcTaAq7UL4FIDs5jWEgA8yW676FTo=@protonmail.com> <b448db72-549e-f748-3851-9d297b7ea05d@gmail.com>
Feedback-ID: 25557543:user:proton
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Denis,

I have removed 'l_dbus_message_unref()', however the main loop still seems =
to stop at 'counter =3D 8' and the message callback does not get invoked.

int counter =3D 0;
while (true) {
  printf("counter: %d\n", counter++);
  int timeout =3D l_main_prepare();
  l_main_iterate(timeout);
}

If I replace with 'l_main_iterate(0)', counter does get incremented as you =
would expect. However, the message callback still does not get invoked.

--
Ryan McClue, Sydney

------- Original Message -------
On Wednesday, June 15th, 2022 at 12:48 AM, Denis Kenzior <denkenz@gmail.com=
> wrote:


> Hi Ryan,
>
> <snip>
>
> > struct l_dbus_message *msg =3D l_dbus_message_new_method_call(conn, "or=
g.bluez", "/org/bluez/hci0",
> > "org.bluez.Adapter1", "StartDiscovery");
> >
> > l_dbus_send_with_reply(conn, msg, start_discovery_callback, NULL, NULL)=
;
> >
> > l_dbus_message_unref(msg);
>
>
> l_dbus_send* take ownership of the message, so it is wrong to unref it he=
re.
>
> Regards,
> -Denis
