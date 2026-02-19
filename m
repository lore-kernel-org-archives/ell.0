Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 9C8523009ED
	for <ell@lists.linux.dev>; Thu, 19 Feb 2026 11:55:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771502147; cv=none; b=nTZu8t017QDEqXf0AOYuI96XlkoTlnJ3Cs6dfKHnWgqM/9tXKI56MlrHR5loepzj7wKnEAkbfwiFp1V3xIP6iN4LdvL4hxwDrShqpeIC27GBC4O9bALUzqW7fxNeZb2Tl4wNZS7s/TtW+ZI0YW0RiBZ8M0jQ2VNJcC06PmWDbd4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771502147; c=relaxed/simple;
	bh=0BGclomnuJtXvyiYvZd0tnbXpUpzbC1HcGyKWNkvSmw=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=Nl4s3Mq0LDHF4Wuctr6NMApgpZBOqiabtHa+hv89oPfA5vpLEmZcYLda/Nuv65lDKPH83XoIK2Tsriz68LzB3WJZrKf7KMZpvx3z/ARLS6HisFV9Ro3bi1yKglsw6GZWjmqS0Z326VDyK9exa4oLV8do+GQvNz6brH0AHaxKLtQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4fefc5c5.dip0.t-ipconnect.de [79.239.197.197])
	by mail.holtmann.org (Postfix) with ESMTPSA id 9E362CECBE;
	Thu, 19 Feb 2026 12:55:37 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.400.21\))
Subject: Re: [PATCH v2] unit: Skip tests that rely on PKCS#8 when parser is
 missing
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20260219100721.2178113-1-hadess@hadess.net>
Date: Thu, 19 Feb 2026 12:55:26 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <BC761BEA-8C6C-4933-B687-5CD0B09DED45@holtmann.org>
References: <20260219100721.2178113-1-hadess@hadess.net>
To: Bastien Nocera <hadess@hadess.net>
X-Mailer: Apple Mail (2.3864.400.21)

Hi Bastien,

> Add pre-check to tests that need the pkcs8_key_parser module loaded
> (whether built-in or external), and allow tests that rely on it to =
fail.
>=20
> This makes it possible to run the test suite successfully even on
> systems where we might not be able to load modules if they're missing
> such as CIs, or other systems where we lack permissions.
> ---
>=20
> Changes since v1:
> - Use precheck test mechanism instead of flags
>=20
> unit/test-pem.c | 154 +++++++++++++++++++++++++++++++++---------------
> 1 file changed, 105 insertions(+), 49 deletions(-)
>=20
> diff --git a/unit/test-pem.c b/unit/test-pem.c
> index 7ee0597ed172..306e3a4f8656 100644
> --- a/unit/test-pem.c
> +++ b/unit/test-pem.c
> @@ -10,6 +10,7 @@
> #endif
>=20
> #include <assert.h>
> +#include <sys/stat.h>
>=20
> #include <ell/ell.h>
>=20
> @@ -136,6 +137,18 @@ static const struct pem_from_data_test =
single_line_cert_chain =3D {
> "-----END CERTIFICATE-----\n",
> };
>=20
> +static bool pkcs8_key_parser_precheck(const void *data)
> +{
> + struct stat s;
> +
> + /* Despite the path, this directory exists whether the module
> + * is external or built-in. */
> + if (stat ("/sys/module/pkcs8_key_parser", &s) !=3D 0)
> + return false;
> +
> + return S_ISDIR (s.st_mode);
> +}
> +

you don=E2=80=99t think doing it like this is better:

+static bool test_load_precheck(const void *data)
+{
+       return true;
+}
+
+#define add_file_test(name, data) l_test_add_data_func_precheck(name, =
data, \
+                                       test_load_file, =
test_load_precheck, 0);
+
 int main(int argc, char *argv[])
 {
        l_test_init(&argc, &argv);
@@ -499,8 +507,7 @@ int main(int argc, char *argv[])
                        test_load_file,
                        =
TEST_LOAD_PARAMS("cert-entity-pkcs12-rc4-sha384.p12",
                                                true, true, true, =
true));
-       l_test_add("pkcs#12/Combined PKCS#5 ciphers + SHA512",
-                       test_load_file,
+       add_file_test("pkcs#12/Combined PKCS#5 ciphers + SHA512",
                        =
TEST_LOAD_PARAMS("cert-entity-pkcs12-pkcs5-sha512.p12",
                                                true, true, true, =
true));

I would most likely also push the TEST_LOAD_PARAMS into the =
add_file_test() macro, but seems a bit more work.

Regards

Marcel

