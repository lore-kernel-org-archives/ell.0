Received: from mail-qk1-f170.google.com (mail-qk1-f170.google.com [209.85.222.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A0736104
	for <ell@lists.linux.dev>; Tue,  9 Jan 2024 04:06:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CjzS7h3z"
Received: by mail-qk1-f170.google.com with SMTP id af79cd13be357-7810827e54eso259584085a.2
        for <ell@lists.linux.dev>; Mon, 08 Jan 2024 20:06:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1704773187; x=1705377987; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=GSFR6Cr8ruLF+fnpNrgAK91yFPp1vGhQn06L++zoFpM=;
        b=CjzS7h3zA3swSclEYH44IJH2ZAX2M2yd3PD97kVF4XBoj1ek4AriuDBohh5lRjF0dF
         +ybdHa+hRzAvx3Rlqpgup2ZImqODfM1hS6A/pioSdltsWGTsXu5p///4Uyutfmt6cF4y
         gQkCm8pdfXFvwkN7mwnun3ZN+J7pMPmIjlbR57g8Mdtt8V/DWdlUYm5kIFcCfmEJXIAc
         yZkIsP5I0/uJ0DvOAUos5Q+LYph4BONCjSmgBCJnpNk3Ysro/pBwI5zqIP5YGOU5JRfN
         Vv+riShPyoUK8L1nO0umKL/rsVKj5zLCg9/u4LRGVU9dyy4Ch9uQxOAR5D2VC/ntkWSq
         gPiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704773187; x=1705377987;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=GSFR6Cr8ruLF+fnpNrgAK91yFPp1vGhQn06L++zoFpM=;
        b=I8NrBA7xY8u+79M66wdHYPAj6Ku1ToRustCze9ZMEAqrWqjm7mDUc0KGiq2pspV4Ie
         akk0Pnlx2OdtXV0g4OqAlPHEEpekQ9p/nrKWxcmKLru5NbV7qievIetcmC+ZQND8g++v
         dDd8MMB+IcP40/4zR9rVxgD66z54RaEaU7uvjoyijYT7UgyrHTi3fQ/zj+8veameyvRb
         B/7hY7J22UI5J5mWyJ1fyfIpzp/vOfAtWMdc0m//oRUUD5m30c911aAmC4BhnDs7+bOP
         q0xp+6abB4eMFjQIn6qF44NQpTPUXk9t6tm1K6NGydutVwBxL6MIWCQxSW3/Vw7qxPIi
         5uwA==
X-Gm-Message-State: AOJu0YwZVtDoVxRP7ELUddt9QF+kabLgE7F+1Vng1J/MzI5weZ73Z+at
	J5JkW1rzLOFgMVGBSjxb5QJ3opBKo2I=
X-Google-Smtp-Source: AGHT+IFJpm65PtHyTxK7Q+np/jDmUJUt5aVrMxgMURe6wX93XizRj4xJwSkjsK4o/GOvKOmhX5xAsw==
X-Received: by 2002:a05:620a:379f:b0:783:668:a7b9 with SMTP id pi31-20020a05620a379f00b007830668a7b9mr4397029qkn.85.1704773186678;
        Mon, 08 Jan 2024 20:06:26 -0800 (PST)
Received: from LOCLAP699.rst-02.locus (50-78-19-50-static.hfc.comcastbusiness.net. [50.78.19.50])
        by smtp.gmail.com with ESMTPSA id y11-20020a05620a25cb00b007830ce180basm462560qko.120.2024.01.08.20.06.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 08 Jan 2024 20:06:26 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] dhcp: fix overflow causing retries to stop
Date: Mon,  8 Jan 2024 20:06:21 -0800
Message-Id: <20240109040621.1248647-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If DHCP is in a SELECTING/REQUESTING state and the number of attempts
reached a value where 2 << attempts overflowed an unsigned int the
next timeout would become zero, causing DHCP to never retry.

Since 5 attempts results in a value of 64 we can instead just limit
the attempts to 5, and set next_timeout to 64 after that as the spec
requires.

Fixes: f130c448 ("dhcp: Introduce timeout fuzzing")
---
 ell/dhcp.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index ece3e23..4f8b369 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -557,9 +557,14 @@ static void dhcp_client_timeout_resend(struct l_timeout *timeout,
 		 * RFC 2131 Section 4.1:
 		 * "The retransmission delay SHOULD be doubled with subsequent
 		 * retransmissions up to a maximum of 64 seconds.
+		 *
+		 * More than 5 attempts will trigger the maximum, don't increase
+		 * any more to avoid overflowing next_timeout.
 		 */
-		client->attempt += 1;
-		next_timeout = minsize(2 << client->attempt, 64);
+		if (client->attempt > 5)
+			next_timeout = 64;
+		else
+			next_timeout = 2 << client->attempt++;
 		break;
 	case DHCP_STATE_INIT:
 	case DHCP_STATE_INIT_REBOOT:
-- 
2.34.1

