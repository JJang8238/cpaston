<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, dao.UserDAO, dto.User" %>

<%
    UserDAO dao = new UserDAO();
    List<User> users = dao.getAllUsers();
%>

<h3 class="fw-bold mb-4">회원 관리</h3>

<table class="table table-striped table-bordered">
    <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>아이디</th>
            <th>이름</th>
            <th>이메일</th>
            <th>권한</th>
            <th style="width:120px;">관리</th>
        </tr>
    </thead>
    <tbody>
    <%
        if (users == null || users.isEmpty()) {
    %>
        <tr><td colspan="6" class="text-center text-muted">등록된 회원이 없습니다.</td></tr>
    <%
        } else {
            for (User u : users) {
    %>
        <tr>
            <td><%=u.getId()%></td>
            <td><%=u.getUsername()%></td>
            <td><%=u.getName()%></td>
            <td><%=u.getEmail()%></td>
            <td><%=u.getRole()%></td>
            <td>
                <form method="post" action="<%=request.getContextPath()%>/admin/deleteUser"
                      onsubmit="return confirm('정말 삭제하시겠습니까?');">
                    <input type="hidden" name="id" value="<%=u.getId()%>">
                    <button class="btn btn-danger btn-sm w-100">삭제</button>
                </form>
            </td>
        </tr>
    <%
            }
        }
    %>
    </tbody>
</table>
