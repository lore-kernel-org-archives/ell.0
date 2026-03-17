Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7F2E3E63AB
	for <ell@lists.linux.dev>; Tue, 17 Mar 2026 14:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757837; cv=none; b=glBoegab33D34ii54czroFp122/Mawh0wKXL0qawYgU3Xm4pCPgJ1vycPrpd2Up52yL5v5JO7JpV4z3eBpkG3BSzfRQtcm1pzSCTO+l1JZsfaEy81R0cgNInA9wE20fdG7ARmloPoJv94AqMiw38G4gneCzBSyyvEu/ukIKr1CM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757837; c=relaxed/simple;
	bh=UyKIaBZAINFoj/17j4Jt/1wRinubU7GKlYZKOFn3Qpo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=efYK5Vd5t3SJQF98kNMpI4ePUiB/BEaKDyktgA3svmCRZxX8mMWhvKqMRt3T1ERhE37ks91cAPppRuTzhY2C1q9ZY5MPUZPHMmy/iDrIVwbQ7XgkPXbSSS3mZpMeai2VZY/Fxcfis4wwwkMCwHgmC9xRM6GOPB/GYJfjseri9b8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id E726F3EE05;
	Tue, 17 Mar 2026 14:30:26 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 1/4] unit: Fix incorrect basename usage
Date: Tue, 17 Mar 2026 15:28:54 +0100
Message-ID: <20260317143018.628844-2-hadess@hadess.net>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260317143018.628844-1-hadess@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftddugeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveethfelveejffetkeelheehueejlefhvdehteehgfeghfekgfdvfefhgeekieetnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepgfejvdeihfefgffgtdehpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth

The code called basename(), which requires either relying on the GNU
libc, or including libgen.h to get access to the POSIX implementation.

As neither was done, and the output of basename() was not freed, it's
likely that the intent was to use the library-exported l_basename()
instead which does not output an allocated string.

ninja: job failed: clang -Isubprojects/ell-0.83/unit/test-path.p -Isubprojects/ell-0.83/unit -I../subprojects/ell-0.83/unit -Isubprojects/ell-0.83 -I../subprojects/ell-0.83 -fdiagnostics-color=always -D_FILE_OFFSET_BITS=64 -Wall -Winvalid-pch -O0 -g -DHAVE_CONFIG_H '-DUNITDIR="/home/runner/work/wrapdb/wrapdb/subprojects/ell-0.83/unit/"' '-DCERTDIR="/home/runner/work/wrapdb/wrapdb/_build/subprojects/ell-0.83/unit/"' -MD -MQ subprojects/ell-0.83/unit/test-path.p/test-path.c.o -MF subprojects/ell-0.83/unit/test-path.p/test-path.c.o.d -o subprojects/ell-0.83/unit/test-path.p/test-path.c.o -c ../subprojects/ell-0.83/unit/test-path.c
../subprojects/ell-0.83/unit/test-path.c:65:9: error: call to undeclared function 'basename'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
   65 |         base = basename(tmp_path);
      |                ^
../subprojects/ell-0.83/unit/test-path.c:65:9: note: did you mean 'l_basename'?
../subprojects/ell-0.83/ell/path.h:20:13: note: 'l_basename' declared here
   20 | const char *l_basename(const char *path);
      |             ^
../subprojects/ell-0.83/unit/test-path.c:65:7: error: incompatible integer to pointer conversion assigning to 'char *' from 'int' [-Wint-conversion]
   65 |         base = basename(tmp_path);
      |              ^ ~~~~~~~~~~~~~~~~~~
---
 unit/test-path.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/unit/test-path.c b/unit/test-path.c
index 1f744234c395..f01fa526aaa1 100644
--- a/unit/test-path.c
+++ b/unit/test-path.c
@@ -55,14 +55,14 @@ static void test_path_find(const void *data)
 	static const char *cant_find = "/foo:/bar:/dir:fr";
 	static const char *can_find = "/tmp";
 	char *tmp_path = l_strdup("/tmp/foobarXXXXXX.tmp");
-	char *base;
+	const char *base;
 	char *path;
 	int fd;
 
 	fd = L_TFR(mkostemps(tmp_path, 4, O_CLOEXEC));
 	assert(fd > 0);
 	L_TFR(close(fd));
-	base = basename(tmp_path);
+	base = l_basename(tmp_path);
 
 	assert(l_path_find(base, cant_find, F_OK) == NULL);
 
-- 
2.53.0

