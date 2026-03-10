Received: from mail.amaanq.com (mail.amaanq.com [152.53.225.105])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C29EE2C11D9
	for <ell@lists.linux.dev>; Tue, 10 Mar 2026 19:48:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=152.53.225.105
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773172127; cv=none; b=MJ6FdBNZBcVr57sCHVkE2piYNXDaWkQmFF1L8kaS+Cz4Hxj1CYZac3YA4xDYJ8xL+GtUDsoFFJruOJ8ASb/FyG6KN2GuEGee7mfCNHTJoac6Cj3HYbjAOoRnrM9dCJpfAuGSO6DbrMywYcbZLtO7iXd/OCoJkCvrMwsKoDVzDp0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773172127; c=relaxed/simple;
	bh=7WBlBl7RY9bFu/5vX0Uv13igQxJQ45NxK2qv4G+rCZA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kXuOY88Ny8Z1/Mg319Ea34TcsItnJdpbC/54uPV6yoZdPjEIqoGYFpQi+OPLBJ15E8DFlZ2951QGAAFlIRc2ugAUuFnsadA2pLoUa3eaHEAO0xh2KC1Lm7n/bDcg3ATluQ9wDu3h7gyhTy+n1FvZPHYfbyQy+M9CE/CXlwJsPIU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=amaanq.com; spf=pass smtp.mailfrom=amaanq.com; dkim=pass (2048-bit key) header.d=amaanq.com header.i=@amaanq.com header.b=OKR8vOiQ; arc=none smtp.client-ip=152.53.225.105
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=amaanq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amaanq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amaanq.com header.i=@amaanq.com header.b="OKR8vOiQ"
DKIM-Signature: v=1; a=rsa-sha256; s=stalwart; d=amaanq.com; c=relaxed/relaxed;
	h=Message-ID:Date:Subject:To:From; t=1773172123; bh=NNmOZijEGEZUJF+iKZgEC5f
	S41DCPn2WPRkS1nUZTn0=; b=OKR8vOiQipOm3Tw9SYkH9Ghj+W+xkYnMZW8NODMmyGP59REv8z
	c01ZFkdi+tqI+SsFnhjKEuSXbwWslqXhtoX/y2jQG38dYmZj+4ogBFTPZ9heDQJ3zVclh+jI26P
	EgATLOdoAoSAkr81x8hTsCWDfmQhNdq565Whhi43ZoeLLxfNulQpVQ+WCKOmZ6oc7yzTqItCDrx
	mjuCpk0xQIagt9qGUZUtJ0ToUuEczzKESXdb26+BCnmUN3v67mQJDpamNq0zYxTtq8CtXJw8uj+
	zcb19zpVIELPPIMQMc7OX4bpdSkNZo/ydcVvEnmavpGqtnHzMdrfiBDm3f87He39zGg==;
From: Amaan Qureshi <git@amaanq.com>
To: ell@lists.linux.dev
Cc: Amaan Qureshi <git@amaanq.com>
Subject: [PATCH] test: only flag parse tests as little-endian-only in test-gvariant-message
Date: Tue, 10 Mar 2026 15:48:37 -0400
Message-ID: <20260310194837.3078283-1-git@amaanq.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The blanket `l_test_set_default_flags(L_TEST_FLAG_LITTLE_ENDIAN_ONLY)`
marks all gvariant-message tests as little-endian-only, but the build
and rewind tests work correctly on big-endian. This causes an XPASS
(unexpected pass) on big-endian systems, which autotools treats as a
test suite failure.

This commit applies the flag only to the three parse tests that compare
against hardcoded little-endian byte sequences.
---
 unit/test-gvariant-message.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/unit/test-gvariant-message.c b/unit/test-gvariant-message.c
index 2df7c9b..8f8589f 100644
--- a/unit/test-gvariant-message.c
+++ b/unit/test-gvariant-message.c
@@ -386,22 +386,22 @@ static void builder_rewind(const void *data)
 
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 
-	l_test_set_default_flags(L_TEST_FLAG_LITTLE_ENDIAN_ONLY);
-
-	l_test_add("Basic 1 (parse)", parse_basic_1, &message_data_basic_1);
+	/* Parse tests compare against little-endian reference data */
+	l_test_add_data_func("Basic 1 (parse)", &message_data_basic_1,
+				parse_basic_1, L_TEST_FLAG_LITTLE_ENDIAN_ONLY);
 	l_test_add("Basic 1 (build)", build_basic_1, &message_data_basic_1);
 
-	l_test_add("Complex 1 (parse)", check_complex_1,
-						&message_data_complex_1);
+	l_test_add_data_func("Complex 1 (parse)", &message_data_complex_1,
+				check_complex_1, L_TEST_FLAG_LITTLE_ENDIAN_ONLY);
 	l_test_add("Complex 1 (build)", build_complex_1,
 						&message_data_complex_1);
 
-	l_test_add("Empty signature (parse)", check_empty_sig,
-						&message_data_empty_sig);
+	l_test_add_data_func("Empty signature (parse)", &message_data_empty_sig,
+				check_empty_sig, L_TEST_FLAG_LITTLE_ENDIAN_ONLY);
 	l_test_add("Empty signature (build)", build_empty_sig,
 						&message_data_empty_sig);
 
 	l_test_add("Message Builder Rewind Complex 1", builder_rewind,
 						&message_data_complex_1);
-- 
2.53.0

