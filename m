Received: from mail-pg1-f172.google.com (mail-pg1-f172.google.com [209.85.215.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 670D57B
	for <ell@lists.linux.dev>; Tue, 25 Apr 2023 09:02:04 +0000 (UTC)
Received: by mail-pg1-f172.google.com with SMTP id 41be03b00d2f7-52867360efcso749242a12.2
        for <ell@lists.linux.dev>; Tue, 25 Apr 2023 02:02:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682413323; x=1685005323;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=/7m3T8DhjoCPVWWgXlyGsv8mOUtkSPia91kaUNUFUF8=;
        b=T6ihCiF+If4AiBLCtof3oaqiSGCJgQwHP8WF+AuqER0E1KZOcbuiML1by6WpaECdSc
         JnqJhhDG2JEQTJOvVIDhY4vVzASEo65+QCv1LM2Ztja7Opeq5VVUfHT+BSCKCQvzwn6T
         inC8RpU4V1Stf3VIOyTpdZz2rCRbHtMD45y331rrO5wM8T576EFRzWTE4HADXcuBxUAc
         pEIq4b3dZ0m3Kj1lBgCkAJrkdRaK1Rz3Fz+vu1p2aY8dwqkzVpfnAQoEavt8v0Qc1UBe
         i6S8VPR6Eoiw/mcyiBVTWaMX/ic4r43jyxdp7mxbBqIjlWRflmeAgHrwVfY7mDNxYrMt
         hpgQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682413323; x=1685005323;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=/7m3T8DhjoCPVWWgXlyGsv8mOUtkSPia91kaUNUFUF8=;
        b=iJlTDLXjS6w3P8KL6kBGqd7c+Cpye7J5TbHL9kamr9n22SNiTVzu2z9+LMr6fquziy
         dG34xRrHHrW9ibl9xnTKcILdjlv3X76WyEqv4EugtNaTuripDDissxLaCUPKDSnOghVr
         oelH/iqpQ/NBAv0kHpcnYIpdx0GmGMMg5lyXpnbMirr+HHgSsEyooGTSEv+dBYLK+zCw
         4kmy36UMkOBOhZBluq+yteNgpqZFWyITkH8xTIc4O76YiUjFcVK75rkRbuz1nHc0BqxW
         CWgTRz5Nnp2GY611tw+7IQDKKpvPykpS0mS6U6+1YxJ1/cuK4XlBzxJwU43a5W/9EVvN
         bldQ==
X-Gm-Message-State: AAQBX9cWvs/GVHXDmj6hTqvSi6sovkIdy/94htq2/1clld3QeNh3hqpZ
	Mxz0i3rlfQ/33B2ulDpTmQwcS9nDB3pi9viiEt0trKm/2f0=
X-Google-Smtp-Source: AKy350bvd+Ym7GwOLaM4ZIXSiidFgpBndrCnYtP6AkUwWjyZrDhmwfG1X5GNLRRDrP3djbQ+1tvww6b2HecBO7pyJHY=
X-Received: by 2002:a17:90a:b001:b0:23f:6958:e931 with SMTP id
 x1-20020a17090ab00100b0023f6958e931mr16958372pjq.46.1682413323193; Tue, 25
 Apr 2023 02:02:03 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Brandon Cheo Fusi <fusibrandon13@gmail.com>
Date: Tue, 25 Apr 2023 10:01:50 +0100
Message-ID: <CAEVJM+pjy7k+to4uYCVBsBL9U0DDJzZ08DLtzvO5SrH-PS6Lxg@mail.gmail.com>
Subject: Static array indices in function parameter declarations
To: ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi everyone,

I'm currently using ell for talking to dbus, and have found it way
more convenient and easier to use as compared to gdbus, or any of the
other bindings I've looked at. So many thanks.

The extern "C"  usage in the header files show the library is allowed
to be compiled with C++ code. However the usage of the C99 feature
that allows one to declare the index of the argument array using the
'static' keyword in some header files (like rtnl.h:110) seems to
prevent this.

Is there a workaround for this issue?  Or should I submit a patch that
removes all usage of this feature.

Regards,
Brandon.
