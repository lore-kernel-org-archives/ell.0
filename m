Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id D7D3426299
	for <ell@lists.linux.dev>; Fri, 13 Feb 2026 20:51:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771015864; cv=none; b=m78ry/DCacaxkTY8R5c071LTqT0tLkQpG/MVrUFxzAIGthumMnxDumL/uhSo7t7MhAqL/88+LNsJVJMb5foxiDOIcio38WncV3QZ6mShvJUES60PXiozAUgJ04rSJxkiBiEkPryA/DXvNtrasAOabsrwv3fZrU6gtGPIr66MS/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771015864; c=relaxed/simple;
	bh=wQ+jk3HBJ25d8pLfx9LF9RAalDTpQ3iSdhGN9Gh3maw=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=N2QJxmEoDMWPotyuVwCfzMPhK+fHys+PbFYGhW8050P1Ki/aB3mgZIyC58csns3GfFxJRav+N8s4pQb6lWWYztvbFdjdPZSCxQrIR0jbWHhq2VEvZQ89KpvkrV1VHneaLgvIyRfscI7gVNVcS3s3Acgzy3cwwbEUZKRI4DFqfcQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9f6bd.dip0.t-ipconnect.de [79.249.246.189])
	by mail.holtmann.org (Postfix) with ESMTPSA id 5F9BECECBE;
	Fri, 13 Feb 2026 21:50:56 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.400.21\))
Subject: Re: [PATCH] unit: Skip tests that rely on PKCS#8 when parser is
 missing
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20260211164200.3968281-1-hadess@hadess.net>
Date: Fri, 13 Feb 2026 21:50:45 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <9C252C4B-652C-41EF-901A-BBA78DFB0FE4@holtmann.org>
References: <20260211164200.3968281-1-hadess@hadess.net>
To: Bastien Nocera <hadess@hadess.net>
X-Mailer: Apple Mail (2.3864.400.21)

Hi Bastien,

> Check whether the kernel has the pkcs8_key_parser module loaded =
(whether
> built-in or external), and allow tests that rely on it to fail.
>=20
> This makes it possible to run the test suite successfully even on
> systems where we might not be able to load modules if they're missing.
> ---
> unit/test-pem.c | 137 +++++++++++++++++++++++++++++++-----------------
> 1 file changed, 88 insertions(+), 49 deletions(-)
>=20
> diff --git a/unit/test-pem.c b/unit/test-pem.c
> index 7ee0597ed172..4ff62ea06d7a 100644
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
> +static bool pkcs8_key_parser_loaded(void)
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

hmm, you just looked at a unit test that I have not converted.

If you look at test-cipher.c for example, you see that I have added =
precheck capability to determine if a test case can be run or not.

static bool aead_cipher_precheck(const void *data)
{
	const struct aead_test_vector *tv =3D data;
	return l_aead_cipher_is_supported(tv->type);
}

> static void destroy_cert(void *cert)
> {
> l_cert_free(cert);
> @@ -384,6 +397,11 @@ static void test_load_file(const void *data)
>=20
> int main(int argc, char *argv[])
> {
> + int flags =3D 0;
> +
> + if (!pkcs8_key_parser_loaded())
> + flags =3D L_TEST_FLAG_ALLOW_FAILURE;
> +
> l_test_init(&argc, &argv);
>=20
> l_test_add("pem/invalid header/test 1", test_pem, &invalid_header1);
> @@ -394,7 +412,7 @@ int main(int argc, char *argv[])
> l_test_add("pem/empty label", test_pem, &empty_label);
> l_test_add("pem/cert chain from data", test_chain_from_data,
> &single_line_cert_chain);
> - l_test_add("pem/private key from data", test_priv_key_from_data, =
NULL);
> + l_test_add_func("pem/private key from data", =
test_priv_key_from_data, flags);

And then I used a macro for the add test case statement

#define add_aead_test(name, data) l_test_add_data_func_precheck(name, =
data, \
						test_aead, =
aead_cipher_precheck, 0);

After that it becomes an easy line in the main() function.

add_aead_test("RFC3610 - Packet Vector #1", &rfc3610_ccm_1);

This makes it clean and easy to change in the future if I want to =
upgrade the test framework.

And I think the unit/test-eapol.c from iwd has some of this done, but =
might could also use a better PKCS#8 support check.

Regards

Marcel

