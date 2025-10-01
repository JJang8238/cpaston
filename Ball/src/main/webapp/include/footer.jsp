<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
</main>
<footer class="py-5 bg-dark mt-5">
  <div class="container px-4 px-lg-5">
    <p class="m-0 text-center text-white">Copyright &copy; 플랩풋볼 2025</p>
  </div>
</footer>

<!-- Bootstrap JS: CSS와 같은 5.3.3 버전으로 통일 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- (선택) CDN 차단 대비 로컬 폴백 -->
<script>
  if (!window.bootstrap) {
    var s = document.createElement('script');
    s.src = '<%=request.getContextPath()%>/vendor/bootstrap/bootstrap.bundle.min.js';
    document.head.appendChild(s);
  }
</script>

<!-- 너의 커스텀 JS -->
<script src="<%=request.getContextPath()%>/js/scripts.js"></script>
</body>
</html>
