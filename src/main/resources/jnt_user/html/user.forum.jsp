<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="acl" type="java.lang.String"--%>
<template:addResources type="css" resources="forum.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.cuteTime.js"/>

<jcr:sql var="numberOfPostsQuery" sql="select [jcr:uuid] from [jnt:post] as p where p.[jcr:createdBy] = '${currentNode.name}'"/>
<c:set var="numberOfPosts" value="${functions:length(numberOfPostsQuery.rows)}"/>
<c:forEach items="${currentNode.properties}" var="property">
    <c:if test="${property.name == 'j:firstName'}"><c:set var="firstname" value="${property.string}"/></c:if>
    <c:if test="${property.name == 'j:lastName'}"><c:set var="lastname" value="${property.string}"/></c:if>
    <c:if test="${property.name == 'j:email'}"><c:set var="email" value="${property.string}"/></c:if>
    <c:if test="${property.name == 'j:organization'}"><c:set var="company" value="${property.string}"/></c:if>
</c:forEach>
<jcr:nodeProperty node="${currentNode}" name="jcr:created" var="registration"/>
<jcr:node var="user" path="${renderContext.user.localPath}"/>

<template:addResources type="css" resources="forum.css"/>

<h3><fmt:message key='forum.user.profil'/></h3>

<div>
    <ul class="list-forum-user-profil">
        <jcr:nodeProperty var="picture" node="${currentNode}" name="j:picture"/>
        <c:if test="${not empty country}">
            <li>
                <strong><fmt:message key='country'/>: </strong>${fn:toLowerCase(country.string)} <img src="<c:url value='${url.base}/../../../css/images/flags/plain/flag_${fn:toLowerCase(country.string)}.png'/>"/>
            </li>
        </c:if>
        <li>
         <strong><fmt:message key='pseudo'/>: </strong>${currentNode.name}
        </li><li>
         <strong><fmt:message key='name'/>: </strong>${firstname}&nbsp;${lastname}
        </li><li>
         <strong><fmt:message key='company'/>: </strong>${company}
        </li><li>
         <strong><fmt:message key='email'/>: </strong>${email}
        </li><li>
         <strong><fmt:message key='registration.date'/>: </strong><fmt:formatDate value="${registration.time}" type="date" dateStyle="medium"/>
        </li><li>
        <strong><fmt:message key='number.of.posts'/>: </strong>${numberOfPosts}
        </li>
    </ul>
</div>


