Received: from mail-qt1-f181.google.com (mail-qt1-f181.google.com [209.85.160.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76C1B13CFBC
	for <ell@lists.linux.dev>; Wed,  7 Aug 2024 17:59:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723053591; cv=none; b=YLTGKb33RoO/BEahMooI25fGi2I5VdFdQjeKo43s+PUTTUe0NWmZ/cf7bNl+5r+QuXWDLMdT8tNffmHA/8O0TRfTc5mg46pL0OgfIHzTARHEv1SAHVWiXTVJKOQVa9qRSAu7Rrt3ykiiBOCDOv2j4wlkfgmhgcU8grFd36TfaWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723053591; c=relaxed/simple;
	bh=ETjjx3aL9ERI1a/look1WI3VPipJJngiyJLuIXy9n9M=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=aCuKF8cK+Da7IaxpvRiKH9DDJWG4AnU5swj4Vczp7e/5m5LJ6VF5NHb1RsKPxv5rj59qTRfI06jKJTZe4H0x5bHrR6e8hpl3TmIKKNu0jCGLcHmn227wUkiiR9euoahVfncxGbneWfggzfUkMUfXyeBk3wj8axOGuCs+qxISIsc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=W3zeEZql; arc=none smtp.client-ip=209.85.160.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W3zeEZql"
Received: by mail-qt1-f181.google.com with SMTP id d75a77b69052e-44ff9281e93so841161cf.2
        for <ell@lists.linux.dev>; Wed, 07 Aug 2024 10:59:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1723053589; x=1723658389; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=zF1Ew/xLFCHUGeL4XEpgjxnr5z0l9qmH0oG/xMDm4yo=;
        b=W3zeEZqljJtrX3tbXuSlEI45CzTztwUnMmcuV/jLwEVPU59Mqi4KbwFyzwRCq393gl
         COZtKpTR1ZbWAK/zUIeZI1G5u3nyygoJQKufDLa4GVmli9pZwXSnnbDO1CeHcX4qTK5J
         1S8ZqnieZHOf7owDa3z7I67LU5rpkawsNwEDO/qXZbD9KmGKgsJSkVlDJeKWClEQIcYF
         z3P6VcAzKt5F0UxrKN6RLbBKPNqS4Cm5PnZFX9UI8gB0lBAlFIVtXPRLEYG4c8EHJnIp
         gf91Phmfi+hmxif6qp5WPVBsjZRzyl/SCfVFZKwz8RZQkH6tj8xPX1kKMDLJ+kD8SvGO
         z+PQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1723053589; x=1723658389;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=zF1Ew/xLFCHUGeL4XEpgjxnr5z0l9qmH0oG/xMDm4yo=;
        b=b9yNBn1UhdRgtD6/lmDsw1nmo43jjowH/IdZJs3gajQbzxoh6rLeMUvCz1JvG2Uwmj
         MNkfDtIqpIMdIeKA/nPeALbv13niSWauJK10Pz7wKKSpeamSRy/0u+DEQEZTnZy460Fk
         EkQqHTR4apRHaWrfkUUMezgEUmjv31D9nkSb4qBpBPcQ3gu5XF+VW7Ci0Pj+/jbgGj9Z
         OjSW9+1vSKXJ8mj9WdY6bL3ay/J6wqYZ0MbZ56A530NkgMjxRV6jVqedWXukOwcvNCaS
         P9l22Wb37T8ajb8cs/yJGGXSVDUeE6JhjlNVwWecU4k3GCxLgk6PjZ9JgzvAlvbmbYhQ
         BFiQ==
X-Gm-Message-State: AOJu0YwGWYPt7CS296aWFzq1cZmwrrGN7y0TyImRoeBsSoxLtyHdHZGg
	iuEpXMHdjelHY8zMJEv5tUl1H0kr024w4pvV8kAX9aVD99p968sOpVMJ8A==
X-Google-Smtp-Source: AGHT+IG3XqRPI8I9Nv79OYjb1ImuUP6d8W5+E6vcPmJK8HukIMoPDtVGI9ImiLM3oMjHutJa69svnQ==
X-Received: by 2002:a05:622a:1212:b0:440:ccb8:af2a with SMTP id d75a77b69052e-451892708b7mr303543961cf.12.1723053589198;
        Wed, 07 Aug 2024 10:59:49 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-451c87d95e1sm6596471cf.76.2024.08.07.10.59.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Aug 2024 10:59:48 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] dbus: add l_dbus_object_set_data()
Date: Wed,  7 Aug 2024 10:59:43 -0700
Message-Id: <20240807175943.170002-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240807175943.170002-1-prestwoj@gmail.com>
References: <20240807175943.170002-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Modifies the user data of an existing DBus object.
---
 ell/dbus.c  | 13 +++++++++++++
 ell/dbus.h  |  2 ++
 ell/ell.sym |  1 +
 3 files changed, 16 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index a1ce09e..cd14eef 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1694,6 +1694,19 @@ LIB_EXPORT void *l_dbus_object_get_data(struct l_dbus *dbus, const char *object,
 							interface);
 }
 
+LIB_EXPORT bool l_dbus_object_set_data(struct l_dbus *dbus, const char *object,
+				const char *interface, void *user_data)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_set_interface_data(dbus->tree, object,
+							interface, user_data);
+}
+
 LIB_EXPORT bool l_dbus_object_manager_enable(struct l_dbus *dbus,
 						const char *root)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index 21bd4bf..6ec9c83 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -227,6 +227,8 @@ bool l_dbus_object_remove_interface(struct l_dbus *dbus, const char *object,
 					const char *interface);
 void *l_dbus_object_get_data(struct l_dbus *dbus, const char *object,
 				const char *interface);
+bool l_dbus_object_set_data(struct l_dbus *dbus, const char *object,
+				const char *interface, void *user_data);
 
 bool l_dbus_object_manager_enable(struct l_dbus *dbus, const char *root);
 
diff --git a/ell/ell.sym b/ell/ell.sym
index 0dad73f..aafc0a4 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -225,6 +225,7 @@ global:
 	l_dbus_object_add_interface;
 	l_dbus_object_remove_interface;
 	l_dbus_object_get_data;
+        l_dbus_object_set_data;
 	l_dbus_object_manager_enable;
 	l_dbus_add_disconnect_watch;
 	l_dbus_add_service_watch;
-- 
2.34.1

