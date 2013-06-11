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
    NSLog(@"  maxAttempts=%d",maxAttempts);
    NSLog(@"TraceRoute");
    
    return self;
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
    //NSLog(@"doTraceRoute");
    struct hostent *host_entry = gethostbyname(host.UTF8String);
    char *ip_addr;
    ip_addr = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    struct sockaddr_in destination,fromAddr;
    int recv_sock;
    int send_sock;
    Boolean error = false;
    
    isrunning = true;
    // On vide la TableView
    [Hop clear];
    
    // Création de la socket destinée à traiter l'ICMP envoyé en retour.
    if ((recv_sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)) < 0) {
        NSLog(@"ERROR Could not create recv_sock.");
    }
    // Création de la socket destinée à 
    if((send_sock = socket(AF_INET , SOCK_DGRAM,0))<0){
        NSLog(@"ERROR Could not cretae send_sock.\n");
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
    
    //NSLog(@"maxAttempts=%d",maxAttempts);
    
    int ttl = 1;
    int try = 0;
    // Positionné à true lorsqu'on reçoit la trame ICMP en retour.
    bool icmp = false;
    Hop *routeHop;
    while(ttl < maxTTL) {
        //NSLog(@"ttl=%d",ttl);
        memset(&fromAddr, 0, sizeof(fromAddr));
        if(setsockopt(send_sock, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl))<0) {
            error = true;
            NSLog(@"ERROR in setsockopt\n");
        }
        
        try = 0;
        icmp = false;
        while(try < maxAttempts) {
            //NSLog(@"try=%d",try);
            try++;
            if (sendto(send_sock,cmsg,sizeof(cmsg),0,(struct sockaddr *) &destination,sizeof(destination)) != sizeof(cmsg) ) {
                error = true;
                NSLog (@"ERROR in send to...\n@");
            }
            int res = 0;
            
            if( (res = recvfrom(recv_sock, buf, 100, 0, (struct sockaddr *)&fromAddr,&n))<0) {
                error = true;
                NSLog(@"ERROR [%d/%d] %s; recvfrom returned %d\n", try, maxAttempts, strerror(errno), res);
            } else {
                char display[16]={0};
                icmp = true;
                inet_ntop(AF_INET, &fromAddr.sin_addr.s_addr, display, sizeof (display));
                NSString *hostAddress = [NSString stringWithFormat:@"%s",display];
                NSString *hostName = [BDHost hostnameForAddress:hostAddress];
                
                routeHop = [[Hop alloc] initWithHostAddress:hostAddress hostName:hostName ttl:ttl];
                [Hop addHop:routeHop];
                /*if(_delegate != nil) {
                    [_delegate newHop:routeHop];
                }*/
                
                //NSLog(@"Received packet from:%@/%@ for TTL=%d\n",hostAddress,hostName,ttl);
                
                break;
            }
            // On teste si l'utilisateur a demandé l'arrêt du traceroute
            @synchronized(running) {
                if(!isrunning) {
                    ttl = maxTTL;
                    // On force le statut d'icmp pour ne pas générer un Hop en sortie de boucle;
                    icmp = true;
                    break;
                }
            }
        }
        // En cas de timeout
        if(!icmp) {
            routeHop = [[Hop alloc] initWithHostAddress:@"*" hostName:@"*" ttl:ttl];
            [Hop addHop:routeHop];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_delegate != nil) {
                [_delegate newHop:routeHop];
            }
        });
        ttl++;
    }
    isrunning = false;
    // On averti le delegate que le traceroute est terminé.
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate end];
    });
    return error;
}

/**
 * Méthode demandant l'arrêt du traceroute.
 */
- (void)stopTrace
{
    @synchronized(running) {
        isrunning = false;
    }
}

/**
 * Retourne le nombre de hops couramment trouvés
 */
- (int)hopsCount {
    return [Hop hopsCount];
}

/**
 * Retourne un boolean indiquant si le traceroute est toujours actif.
 */
- (bool)isRunning {
    return isrunning;
}

@end
