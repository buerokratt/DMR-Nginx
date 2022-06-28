async function forwardToParticipant(r) {
    r.return(202);
    r.subrequest('/forward-to-participant', {method: 'POST'}, (forwardResponse) => {
        if (forwardResponse.status !== 202) {
            r.error(`Failed to forward message, response status ${forwardResponse.status} !== 202.\n${njs.dump(r.headersIn)}`);
            r.subrequest('/send-error-message', {method: 'POST'}, (errorResponse) => {
                if (errorResponse.status !== 202) {
                    r.error(`Failed to notify sender about forwarding error, response status ${forwardResponse.status} !== 202.\n${njs.dump(r.headersIn)}`);
                }
            });
        }
    })
}

export default {forwardToParticipant};
