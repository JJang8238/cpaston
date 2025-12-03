<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>

<%
    UserDAO dao = new UserDAO();
    List<User> users = dao.getAllUsers();
%>

<style>
.btn-role {
    white-space: nowrap;
    min-width: 50px;
}

</style>



<h3 class="fw-bold mb-4">회원 관리</h3>

<table class="table table-bordered table-striped shadow-sm">
    <thead class="table-dark text-center">
        <tr>
            <th style="width:60px;">ID</th>
            <th style="width:160px;">아이디</th>
            <th style="width:160px;">이름</th>
            <th>이메일</th>
            <th style="width:260px;">권한 변경</th>
            <th style="width:120px;">삭제</th>
        </tr>
    </thead>

    <tbody class="align-middle">
    <%
        if (users == null || users.isEmpty()) {
    %>
        <tr>
            <td colspan="6" class="text-center text-muted py-4">등록된 회원이 없습니다.</td>
        </tr>
    <%
        } else {
            for (User u : users) {
    %>

        <tr>
            <td class="text-center"><%= u.getId() %></td>
            <td><%= u.getUsername() %></td>
            <td><%= u.getName() %></td>
            <td><%= u.getEmail() %></td>

            <!-- 권한 변경 -->
            <td>
    			<form method="post"
          			action="<%= request.getContextPath() %>/admin/updateRole"
         		 	class="d-flex align-items-center gap-2">

        			<input type="hidden" name="id" value="<%= u.getId() %>">

        			<select name="role" class="form-select form-select-sm">
            			<option value="student" <%= u.getRole().equals("student") ? "selected" : "" %>>users</option>
            			<option value="admin" <%= u.getRole().equals("admin") ? "selected" : "" %>>admin</option>
        			</select>

					<button class="btn btn-primary btn-sm btn-role">변경</button>
    			</form>
			</td>

            <!-- 삭제 -->
            <td class="text-center">
                <form method="post"
                      action="<%= request.getContextPath() %>/admin/deleteUser"
                      onsubmit="return confirm('정말 삭제하시겠습니까?');">

                    <input type="hidden" name="id" value="<%= u.getId() %>">
                    <button class="btn btn-danger btn-sm px-3">삭제</button>

                </form>
            </td>
        </tr>

    <% 
            }
        }
    %>
    </tbody>
</table>
