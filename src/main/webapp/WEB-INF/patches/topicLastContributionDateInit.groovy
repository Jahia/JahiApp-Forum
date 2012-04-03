import javax.jcr.*
import javax.jcr.query.*

import org.jahia.services.content.*

def log = log;

log.info("Start checking for JahiApp module types");

Integer updated = JCRTemplate.getInstance().doExecuteWithSystemSession(null,"live",null, new JCRCallback<Integer>() {
    public Object doInJCR(JCRSessionWrapper session) throws RepositoryException {
        int count = 0;
log.info("ws : {}", session.getWorkspace().getName());
        for (NodeIterator postIterator = session.getWorkspace().getQueryManager()
                        .createQuery("SELECT * FROM [jnt:post] as post where ISDESCENDANTNODE(post,['/sites/ACME/home/forum']) order by [jcr:lastModified]",
                                Query.JCR_SQL2).execute().getNodes(); postIterator .hasNext();) {
            JCRNodeWrapper post = (JCRNodeWrapper) postIterator.nextNode();
log.info("looking for topic on post : {}", post.getPath());
            if (post.getParent().isNodeType("jnt:topic")) {
String subject = post.getProperty("jcr:created").getString();
post.getParent().setProperty("topicLastContributionDate",subject);
session.save();
log.info("update topic : {}", post.getParent().getName());
            }
            count++;
        }
        if (count > 0) {
            //session.save();
        }
        return count;
    }
});