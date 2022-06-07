Received: from mail-40138.protonmail.ch (mail-40138.protonmail.ch [185.70.40.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B48067F
	for <ell@lists.linux.dev>; Tue,  7 Jun 2022 11:05:38 +0000 (UTC)
Date: Tue, 07 Jun 2022 11:05:29 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=protonmail3; t=1654599936; x=1654859136;
	bh=WNFLl5kB9CpV54airVeAXNZGQnL+Yw5p2R0xqQDUll0=;
	h=Date:To:From:Reply-To:Subject:Message-ID:Feedback-ID:From:To:Cc:
	 Date:Subject:Reply-To:Feedback-ID:Message-ID;
	b=VazNCugugngq67rjw0CeCt+pEGef/ErEAMaLkN9rBztifH3FIbklt3Smsm3wrz/Th
	 GXR5nWRJtIZMj9HTyoiQsHQw/Lj8nw2Z96PuCXiBTu6Xk6avT4mngJlwy94jx2vGrE
	 LxBpyORKG3HV+OSRtgsc/lVWE9gGfO5Yohf9yYllxtR9/KULFHJw3oKEro4SyHkSHl
	 4YzUzfO3q+IuxsAziHK28Le7f1yYomj0c+KUxytwSSx5cKsvpc2w0N5+yllGsXfttS
	 QklXDdghsPUwbWcRWrhAnareHs9CzDT2djNQq7q2f2ijrShtf7puKvGkl/hoSJNeyu
	 d12Ia1VGytXwg==
To: "ell@lists.linux.dev" <ell@lists.linux.dev>
From: Ryan McClue <re.mcclue@protonmail.com>
Reply-To: Ryan McClue <re.mcclue@protonmail.com>
Subject: Sending and Receiving DBUS Message
Message-ID: <VVBTpWPl9dQKNCUMJDgYOFMFEgO_VdFuJ60Eu9ZBWznwRfuoIDDnwp17yk8Et0hiD0NaBFbhi5c1qAM0a-sgP85vbvnk17x_1U_efI5rSLM=@protonmail.com>
Feedback-ID: 25557543:user:proton
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Upon examining 'examples/dbus-client.c', it does not seem to contain DBUS m=
essage sending and receiving/parsing.
As a simple example, I want to call the "Get()" method with arguments "org.=
freedesktop.hostname1" and "Hostname". This method is of the interface "org=
.freedesktop.DBus.Properties". I want to parse the return of this method ca=
ll to get the hostname of my machine.
Take my example code (with error handling omitted):

l_main_init();

struct l_dbus *conn =3D l_dbus_new_default(L_DBUS_SYSTEM_BUS);
const char *service =3D "org.freedesktop.hostname1";
const char *object =3D "/org/freedesktop/hostname1";
const char *interface =3D "org.freedesktop.DBus.Properties";
const char *method =3D "Get";

struct l_dbus_message *msg =3D l_dbus_message_new_method_call(conn, service=
, object, interface, method);
const char *get_interface =3D "org.freedesktop.hostname1";
const char *get_property =3D "Hostname";
l_dbus_message_set_arguments(msg, "ss", get_interface, get_property);

///////////////////////////////////
// How to send and parse output????
///////////////////////////////////

l_dbus_destroy(dbus_conn);
l_main_exit();


Could someone please fill in the blanks for me?
Thanks

--
Ryan McClue, Sydney
