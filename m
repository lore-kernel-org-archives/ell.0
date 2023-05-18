Received: from mail-qt1-f180.google.com (mail-qt1-f180.google.com [209.85.160.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A89A17AB6
	for <ell@lists.linux.dev>; Thu, 18 May 2023 16:47:25 +0000 (UTC)
Received: by mail-qt1-f180.google.com with SMTP id d75a77b69052e-3f4fc2a4622so13221511cf.1
        for <ell@lists.linux.dev>; Thu, 18 May 2023 09:47:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684428444; x=1687020444;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=wl9VXN6+DCXaw8hpW9UtzG7TjmlK+kvZdXOozyWctQo=;
        b=Rj/ko6E+suDt0rPvmuV87JTb0pz8zF8sBo/UkYGi6six674Zj6DcQYsjc0zkJpxLry
         TkYzwXLlz8tyYpl3JJj8YuS3EqaPX0e1hJdTwSYd5cvmrZL30HkKBgiX0dIcVII9iVBu
         o/ejPZisOSRYNV/KL8E8sooz1lrycKHr9DT8KDGs7W9bBVCNZxyD1wdXUjs1eHBZDd5G
         FHz4vk30W7QBRak4ZGxMb1p5zVGEbORR38TPv6HQL4VirZ6yf7fDzSRdoSD2yjaraVp9
         0r74YdHdXV9u+sVfrwT0E6KYAY8AdMwVZkR1WqSH8UlvIgjXtArhKc89AbqMWnD8sd7V
         dddw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1684428444; x=1687020444;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=wl9VXN6+DCXaw8hpW9UtzG7TjmlK+kvZdXOozyWctQo=;
        b=VaiVHhu7iHltL29QyDp+az5xGGLGwcMht5VsUFbCnHwwMlEvXZ60Ge5h45G5AUTnCy
         V39450bHDV4HeoDVsBPb58ByD854ykj3yQBBCuNQhVxAJQa7oCSiI4SS3FPSM+CvUB7K
         ZmAdlZwsjf2zip4hV5nu5RB+PNCExfPRfoBZIUNVR3rNU38f+yB6pDD7wq1B6cTsdcFA
         aV4ciWIe29S8T67M0qaj/lZhmTK1nPr6+plfJjPyv915H3CQOTn6X8bS0eVvHjTqW5wK
         kZkty3jphdnaUhR+8hXdD5yAI8UhTGv6BTovrXlM3Z2810oMSTBtqrqInVUCCSW3F3vK
         2c9A==
X-Gm-Message-State: AC+VfDxbKBQTEGGJ3i+//hvGuI0BOcn9cQQB0aBmbPbILdwRbxvGgqBs
	IhN2W2QrWktKpz3AXgIEitRfAd1U79I=
X-Google-Smtp-Source: ACHHUZ4+pliVSNaOOv5eSQZUVFYHV0tfJh1jFUb9VcmPll7KvrlFQb6BoG7gV7K7hkVg9IBvHD3oBw==
X-Received: by 2002:ac8:5bcc:0:b0:3f2:655a:a77 with SMTP id b12-20020ac85bcc000000b003f2655a0a77mr506876qtb.49.1684428443866;
        Thu, 18 May 2023 09:47:23 -0700 (PDT)
Received: from LOCLAP699.cardinalhealth-columbus.locus (50-78-19-50-static.hfc.comcastbusiness.net. [50.78.19.50])
        by smtp.gmail.com with ESMTPSA id gc11-20020a05622a59cb00b003f38b4167e5sm634510qtb.2.2023.05.18.09.47.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 18 May 2023 09:47:23 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] genl: fix l_genl_family_cancel to wait for NLMSG_DONE
Date: Thu, 18 May 2023 09:47:15 -0700
Message-Id: <20230518164715.275506-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If a genl request was already sent to the kernel a call to
l_genl_family_cancel would remove it from the pending list
immediately. This then allowed l_genl_family_send to queue
another message before the previous/canceled message was
completed. This is not how l_genl is intended to work.

Instead we can clean up the request immediately in
l_genl_family_cancel but not remove it from the queue. This
will prevent any more messages from being sent until NLMSG_DONE
was received for the canceled message.
---
 ell/genl.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 4ed95df..006edf2 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1910,11 +1910,23 @@ LIB_EXPORT bool l_genl_family_cancel(struct l_genl_family *family,
 	if (request)
 		goto done;
 
-	request = l_queue_remove_if(genl->pending_list, match_request_id,
+	request = l_queue_find(genl->pending_list, match_request_id,
 							L_UINT_TO_PTR(id));
 	if (!request)
 		return false;
 
+	/*
+	 * A message in-flight still needs to wait for NLMSG_DONE so clean up
+	 * for the caller but keep the request queued until its done.
+	 */
+	if (request->destroy)
+		request->destroy(request->user_data);
+
+	request->callback = NULL;
+	request->destroy = NULL;
+
+	return true;
+
 done:
 	destroy_request(request);
 
-- 
2.25.1

