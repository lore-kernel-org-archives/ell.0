Received: from www530.your-server.de (www530.your-server.de [188.40.30.78])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBB481940AD
	for <ell@lists.linux.dev>; Mon, 17 Jun 2024 12:45:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=188.40.30.78
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718628346; cv=none; b=paNBKkEgMZJIN357zDdTs2Zq9TMDvJpRZO9+Yw9HjzmkZrWzyO7R/xHeNXSmO4J8kF5KNmQdEiBUZxkzTnTQZio0ewG6b0SaDeIaIRi37VUjAP1gpsKaHDigxXfVHWIF+xid5RpZy9WkZCwjpwgTDqhhXFv5hWxOKHS8J8kjuo4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718628346; c=relaxed/simple;
	bh=k25Q9m9RA6qBxK9eby3kEvKGGC70RLwMiCflz6qZVv0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Op8DaEkWbXCDgmfoA5V2P1LrM5lMKnBhp2N0PJJiMF2rrD34sFhHxyaKc/dg3OrlOeNfB5oUlmHpySdaX6AAVnr2lbIYUTw1jrajPg0iEBtmO0rh5sJ1Kl6DqaPYhu1qB48xvagagk+s+ssGbjbIpXRIzhBBM9e9W+HG6eErV4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=QNB8ql1J; arc=none smtp.client-ip=188.40.30.78
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="QNB8ql1J"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=geanix.com;
	s=default2211; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:
	Subject:Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References;
	bh=08NtA3P66XJ5LqH6OGpbZw6xzs2GYfWDWL1iXK+QQnE=; b=QNB8ql1JIV0qz+uC6VTKuxylDl
	DkEyxsInX5gelmrxaBBrWC5zmK5fn5TvCvF+eh7kSZZMNc3ht2TuB2H6JUQqXLjBRvTfIPTXxT2D8
	XHlPn1EC1VeNQ4beOFcM27vFl8mJ3u/54RGVnpFFgLGRVrfYYsEjMYdYTQCwhZAEUr5ipIEMjilZr
	ridZdM5rNQrxOoJmu/VFqXa7wPXOOw8xfUYFPtYHISCtJ0XNVWxRpiwM6o7sm+y3C46aMLUW6/3qM
	TkSTGEXA86bAODHQkmO+/Y0IlGz2d34P3LOJaA4z3WlL/UowXphiDRwbVQ0/OHd+REznzdABgb5q1
	6uc9LPJg==;
Received: from sslproxy06.your-server.de ([78.46.172.3])
	by www530.your-server.de with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.94.2)
	(envelope-from <martin@geanix.com>)
	id 1sJBUY-000NcO-ON; Mon, 17 Jun 2024 14:29:43 +0200
Received: from [185.17.218.86] (helo=zen..)
	by sslproxy06.your-server.de with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <martin@geanix.com>)
	id 1sJBUU-00045b-24;
	Mon, 17 Jun 2024 14:29:42 +0200
From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH] unit: don't specify tcp hostname in dbus config
Date: Mon, 17 Jun 2024 14:29:38 +0200
Message-ID: <20240617122939.1249697-1-martin@geanix.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Authenticated-Sender: martin@geanix.com
X-Virus-Scanned: Clear (ClamAV 0.103.10/27309/Mon Jun 17 10:30:25 2024)

Testing dbus with no network interfaces available on the host fails
with:
  dbus-daemon[291]: Failed to start message bus: Failed to lookup host/port: "*:14046": Name or service not known (-2)

Seems like "*" isn't a valid hostname in such cases:
  https://bugs.freedesktop.org/show_bug.cgi?id=28979

According to the linked issue, the fix is to simply omit the host= and
bind= parameters in the config.
---
 unit/dbus.conf | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/dbus.conf b/unit/dbus.conf
index 5fe41a9ad6a6..3651e44538b1 100644
--- a/unit/dbus.conf
+++ b/unit/dbus.conf
@@ -7,7 +7,7 @@
   <allow_anonymous />
 
   <listen>unix:path=/tmp/ell-test-bus</listen>
-  <listen>tcp:host=localhost,bind=*,port=14046,family=ipv4</listen>
+  <listen>tcp:port=14046</listen>
   <apparmor mode="disabled" />
 
   <policy context="default">
-- 
2.45.2

