//
//  TraceRoute.m
//  Traceroute
//
//  Created by Christophe Janot on 06/06/13.
//  Copyright (c) 2013 Christophe Janot. All rights reserved.
//

#import "TraceRoute.h"
#include <netdb.h>
#include <arpa/inet.h>
#import "BDHost.h"

@implementation TraceRoute

- (TraceRoute *)initWithMaxTTL:(int)ttl timeout:(int)timeout maxAttempts:(int)attempts port:(int)port
{
    [Hop HopsManager];
    maxTTL = ttl;
    udpPort = port;
    readTimeout = timeout;
    maxAttempts = attempts;
}

/**
 * Exécution totalement paramétrée du traceroute.
 */
- (void)doTraceRouteToHost:(NSString *)host maxTTL:(int)ttl timeout:(int)timeout maxAttempts:(int)attempts port:(int)port
{
    maxTTL = ttl;
    udpPort = port;
    readTimeout = timeout;
    maxAttempts = attempts;
    [self doTraceRoute:host];
}

/**
 * Exécution du traceroute.
 */
- (Boolean)doTraceRoute:(NSString *)host
{
    struct hostent *host_entry = gethostbyname(host.UTF8String);
    char *ip_addr;
    ip_addr = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    struct sockaddr_in destination,fromAddr;
    int recv_sock;
    int send_sock;
    Boolean error = false;
    
    // Création de la socket destinée à traiter l'ICMP envoyé en retour.
    if ((recv_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)) < 0) {
        NSLog(@"Could not create recv_sock.");
    }
    // Création de la socket destinée à 
    if((send_sock = socket(AF_INET , SOCK_DGRAM,0))<0){
        NSLog(@"Could not cretae send_sock.\n");
    }
    memset(&destination, 0, sizeof(destination));
    destination.sin_family = AF_INET;
    destination.sin_addr.s_addr = inet_addr(ip_addr);
    destination.sin_port = htons(udpPort);
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = readTimeout;
    setsockopt(recv_sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&tv,sizeof(struct timeval));
    char *cmsg = "GET / HTTP/1.1\r\n\r\n";
    socklen_t n= sizeof(fromAddr);
    char buf[100];
    
    int ttl = 0;
    while(ttl < maxTTL) {
        memset(&fromAddr, 0, sizeof(fromAddr));
        if(setsockopt(send_sock, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl))<0) {
            error = true;
            NSLog(@"error in setsockopt\n");
        }
        int try = 0;
        while(try < maxAttempts) {
            try++;
            if (sendto(send_sock,cmsg,sizeof(cmsg),0,(struct sockaddr *) &destination,sizeof(destination)) != sizeof(cmsg) ) {
                error = true;
                NSLog (@"error in send to...\n@");
            }
            int res = 0;
            
            if( (res = recvfrom(recv_sock, buf, 100, 0, (struct sockaddr *)&fromAddr,&n))<0) {
                error = true;
                NSLog(@"an error: %s; recvfrom returned %d\n", strerror(errno), res);
            } else {
                char display[16]={0};
                inet_ntop(AF_INET, &fromAddr.sin_addr.s_addr, display, sizeof (display));
                NSString *hostAddress = [NSString stringWithFormat:@"%s",display];
                NSString *hostName = [BDHost hostnameForAddress:hostAddress];
                
                Hop *routeHop = [[Hop alloc] initWithHostAddress:hostAddress hostName:hostName ttl:ttl];
                [Hop addHop:routeHop];
                if(_delegate != nil) {
                    [_delegate newHop:routeHop];
                }
                
                NSLog(@"Received packet from:%s for TTL=%d\n",display,ttl);
                
                break;
            }
        }
        
        // On teste si l'utilisateur a demandé l'arrêt du traceroute
        @synchronized(running) {
            if(!running) {
                try = maxTTL;
            }
        }
    }
    // On averti le delegate que le traceroute est terminé.
    [_delegate end];
    return error;
}

/**
 * Méthode demandant l'arrêt du traceroute.
 */
- (void)stopTrace
{
    @synchronized(running) {
        running = false;
    }
}

/**
 * Retourne le nombre de hops couramment trouvés
 */
- (int)hopsCount {
    return [Hop hopsCount];
}

@end
