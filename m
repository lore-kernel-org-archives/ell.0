Received: from mslow3.mail.gandi.net (mslow3.mail.gandi.net [217.70.178.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E7952110E
	for <ell@lists.linux.dev>; Thu, 19 Feb 2026 12:34:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.178.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771504454; cv=none; b=hRGfynQtBSpJb5tGMKfxKippd/JkX2CZ8mbSBXMdIao20Yw1gUK+7P+dHlRkg+fjE5ESC3BY06I0gZS2DlJDgy7pm4CqBAVxmdSgS2JX5DMURd83DiI2dwErCQzrJ3+OeURRP8IE1nYFHdaNyS9iQE0l+43CFJlZuOKlGWNNzkw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771504454; c=relaxed/simple;
	bh=KwDTbngDIgutw6bpj/N9gdfDAKVVdIMPEm55tDQgW7E=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=AXMy5yaaO9CGR7AH28akZGSXi5czgQd+ghFFRfM+EmCsoSDjuJndvLlt5Pesp+oEmYWBDSsTmP1PZNVSrsECw+87LAmEwQTTtkwZ3RZxFz4swjcgdKeIiP4p1zwxHExoc4krhiHJGhuoq280mRSKNW2zJU3LMpkm9RY4Lmt99FE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.178.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [IPv6:2001:4b98:dc4:8::222])
	by mslow3.mail.gandi.net (Postfix) with ESMTP id C17EB58292C
	for <ell@lists.linux.dev>; Thu, 19 Feb 2026 12:27:32 +0000 (UTC)
Received: by mail.gandi.net (Postfix) with ESMTPSA id 930CE4433C;
	Thu, 19 Feb 2026 12:27:24 +0000 (UTC)
Message-ID: <6919f2302290cbe792a20b3109f5eb34954324d2.camel@hadess.net>
Subject: Re: [PATCH v2] unit: Skip tests that rely on PKCS#8 when parser is
 missing
From: Bastien Nocera <hadess@hadess.net>
To: Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
Date: Thu, 19 Feb 2026 13:27:24 +0100
In-Reply-To: <BC761BEA-8C6C-4933-B687-5CD0B09DED45@holtmann.org>
References: <20260219100721.2178113-1-hadess@hadess.net>
	 <BC761BEA-8C6C-4933-B687-5CD0B09DED45@holtmann.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.2 (3.58.2-1.fc43) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-Sasl: hadess@hadess.net
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvvdehheefucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpefkuffhvfevffgjfhgtgfgfggesthhqredttderjeenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieffgfehtedtgefgjeeggfffgeeuvdegveekveejfeekkedujeehteffueefffeunecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepleeftdevgfeggeeffeevpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopehmrghrtggvlheshhholhhtmhgrnhhnrdhorhhgpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidru
 ggvvh
X-GND-State: clean
X-GND-Score: -100

On Thu, 2026-02-19 at 12:55 +0100, Marcel Holtmann wrote:
> Hi Bastien,
>=20
> > Add pre-check to tests that need the pkcs8_key_parser module loaded
> > (whether built-in or external), and allow tests that rely on it to
> > fail.
> >=20
> > This makes it possible to run the test suite successfully even on
> > systems where we might not be able to load modules if they're
> > missing
> > such as CIs, or other systems where we lack permissions.
> > ---
> >=20
> > Changes since v1:
> > - Use precheck test mechanism instead of flags
> >=20
> > unit/test-pem.c | 154 +++++++++++++++++++++++++++++++++------------
> > ---
> > 1 file changed, 105 insertions(+), 49 deletions(-)
> >=20
> > diff --git a/unit/test-pem.c b/unit/test-pem.c
> > index 7ee0597ed172..306e3a4f8656 100644
> > --- a/unit/test-pem.c
> > +++ b/unit/test-pem.c
> > @@ -10,6 +10,7 @@
> > #endif
> >=20
> > #include <assert.h>
> > +#include <sys/stat.h>
> >=20
> > #include <ell/ell.h>
> >=20
> > @@ -136,6 +137,18 @@ static const struct pem_from_data_test
> > single_line_cert_chain =3D {
> > "-----END CERTIFICATE-----\n",
> > };
> >=20
> > +static bool pkcs8_key_parser_precheck(const void *data)
> > +{
> > + struct stat s;
> > +
> > + /* Despite the path, this directory exists whether the module
> > + * is external or built-in. */
> > + if (stat ("/sys/module/pkcs8_key_parser", &s) !=3D 0)
> > + return false;
> > +
> > + return S_ISDIR (s.st_mode);
> > +}
> > +
>=20
> you don=E2=80=99t think doing it like this is better:
>=20
> +static bool test_load_precheck(const void *data)
> +{
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return true;
> +}
> +
> +#define add_file_test(name, data)
> l_test_add_data_func_precheck(name, data, \
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 test_load_file,
> test_load_precheck, 0);

It's a lot more work to undo something I already did. The types of
tests that are being run are also too heterogeneous to have one catch-
all macro, and we'll end up with a level of indirection where readers
try to figure out what macros do.

I don't find it more readable, but if you need this to land the patch,
I can make a v3.

> +
> =C2=A0int main(int argc, char *argv[])
> =C2=A0{
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 l_test_init(&argc, &argv);
> @@ -499,8 +507,7 @@ int main(int argc, char *argv[])
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 test_loa=
d_file,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TEST_LOA=
D_PARAMS("cert-entity-pkcs12-rc4-
> sha384.p12",
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 true, true, tr=
ue,
> true));
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 l_test_add("pkcs#12/Combined PKCS#5=
 ciphers + SHA512",
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 test_load_file=
,
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 add_file_test("pkcs#12/Combined PKC=
S#5 ciphers + SHA512",
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TEST_LOA=
D_PARAMS("cert-entity-pkcs12-pkcs5-
> sha512.p12",
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 true, true, tr=
ue,
> true));
>=20
> I would most likely also push the TEST_LOAD_PARAMS into the
> add_file_test() macro, but seems a bit more work.
>=20
> Regards
>=20
> Marcel
