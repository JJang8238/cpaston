package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        Object userObj = (session == null) ? null : session.getAttribute("loginUser");

        // 로그인 안 했으면 차단
        if (userObj == null) {
            resp.sendRedirect(req.getContextPath() + "/noAuth.jsp");
            return;
        }

        // role 확인
        String role = null;
        try {
            role = (String) userObj.getClass().getMethod("getRole").invoke(userObj);
        } catch (Exception ignore) {}

        if (role == null || !role.equalsIgnoreCase("admin")) {
            resp.sendRedirect(req.getContextPath() + "/noAuth.jsp");
            return;
        }

        // 통과
        chain.doFilter(request, response);
    }
}